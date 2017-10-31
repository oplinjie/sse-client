require_relative 'spec_helper'
require 'json'

RSpec.describe SSE::EventSource do
  describe '#sse-client' do
    it 'should return abc' do
      stub_request(:get, 'fakeurl.com/sse-server').
        to_return(
          status: 200,
          headers: { 'Content-Type': 'event-stream' },
          body: "data:abc\n\n"
        )
      es = SSE::EventSource.new('fakeurl.com/sse-server')
      es.message do |data|
        expect(data).to eq('abc')
      end
      con = es.start
    end

    it 'should with headers' do
      stub_request(:get, 'fakeurl.com/sse-server').
        with(
          headers: { 'Authorization': 'PORTAL' })
        .to_return(
          status: 200,
          headers: { 'Content-Type': 'event-stream' },
          body: "data:abc\n\n"
        )
      es = SSE::EventSource.new('fakeurl.com/sse-server', nil, { 'Authorization': 'PORTAL' })
      es.message do |data|
        expect(data).to eq('abc')
      end
      con = es.start
    end

    it 'should with query paramters' do
      stub_request(:get, 'fakeurl.com/sse-server?a=123').
        to_return(
          status: 200,
          headers: { 'Content-Type': 'event-stream' },
          body: "data:abc\n\n"
        )
      es = SSE::EventSource.new('fakeurl.com/sse-server', { a: 123 })
      es.message do |data|
        expect(data).to eq('abc')
      end
      con = es.start
    end

    it 'should return event abc' do
      stub_request(:get, 'fakeurl.com/sse-server').
        to_return(
          status: 200,
          headers: { 'Content-Type': 'event-stream' },
          body: "event:abc\ndata:abc\n\n"
        )
      es = SSE::EventSource.new('fakeurl.com/sse-server')
      es.on 'abc' do |data|
        expect(data).to eq('abc')
      end
      con = es.start
    end
  end
end
