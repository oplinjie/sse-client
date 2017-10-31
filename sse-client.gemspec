# encoding: utf-8

Gem::Specification.new do |s|
  s.name             = "sse-client"
  s.version          = "1.0.0"
  s.date             = Time.now.utc.strftime("%Y-%m-%d")
  s.authors          = "oplinjie"
  s.email            = "oplinjie@163.com"
  s.homepage         = "https://github.com/oplinjie/sse-client"
  s.description      = %q{sse-client is an httpclient library base on restclient to consume Server-Sent Events streaming API.}
  s.summary          = %q{sse-client is an httpclient library to consume Server-Sent Events streaming API.}
  s.extra_rdoc_files = %w(README.md)
  s.files            = Dir["README.md", "Gemfile", "lib/**/*.rb"]
  s.require_paths    = ["lib"]
  s.license          = 'MIT'

  s.add_dependency "rest-client"
  s.add_development_dependency "rspec"
  s.add_development_dependency "bundler"
  s.add_development_dependency "webmock"
  s.add_development_dependency "rake"
end
