lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'webmock/rspec'
require 'sse-client'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.order = :random
  Kernel.srand config.seed
end
