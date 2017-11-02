# encoding: utf-8

require 'restclient'

module SSE
  class EventSource
    # Get API url
    attr_reader :url
    # Get ready state
    attr_reader :ready_state

    # The connection has not yet been established, or it was closed and the user agent is reconnecting.
    CONNECTING = 0
    # The user agent has an open connection and is dispatching events as it receives them.
    OPEN       = 1
    # The connection is not open, and the user agent is not trying to reconnect. Either there was a fatal error or the close() method was invoked.
    CLOSED     = 2

    def initialize(url, query = {}, headers = {}, before_execution_proc: nil)
      @url = url
      @headers = headers
      @headers['params'] = query
      @ready_state = CLOSED
      @before_execution_proc = before_execution_proc

      @opens = []
      @errors = []
      @messages = []
      @on = {}
    end

    def start
      @ready_state = CONNECTING
      listen
    end

    def open(&block)
      @opens << block
    end

    def on(name, &block)
      @on[name] ||= []
      @on[name] << block
    end

    def message(&block)
      @messages << block
    end

    def error(&block)
      @errors << block
    end

    private

    def listen
      block = proc { |response|
        handle_open
        case response.code
        when "200"
          buffer = ""
          response.read_body do |chunk|
            buffer += chunk
            while index = buffer.index(/\r\n\r\n|\n\n/)
              stream = buffer.slice!(0..index)
              handle_stream stream
            end
          end
          close
        else
          handle_error response
        end
      }
      conn = RestClient::Request.execute(method: :get,
                                    url: @url,
                                    headers: @headers,
                                    block_response: block,
                                    before_execution_proc: @before_execution_proc)
    end

    def handle_stream(stream)
      data = ""
      name = nil
      stream.split(/\r?\n/).each do |part|
        /^data:(.+)$/.match(part) do |m|
          data += m[1].strip
          data += "\n"
        end
        /^event:(.+)$/.match(part) do |m|
          name = m[1].strip
        end
      end
      return if data.empty?
      data.chomp!
      if name.nil?
        @messages.each { |message| message.call(data) }
      else
        @on[name].each { |message| message.call(data) } if not @on[name].nil?
      end
    end

    def handle_open
      @ready_state = OPEN
      @opens.each { |open| open.call() }
    end

    def handle_error response
      close
      @errors.each { |error| error.call(response) }
    end

    def close
      @ready_state = CLOSED
    end
  end
end
