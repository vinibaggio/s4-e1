require 'rubygems'
require 'bundler/setup'
Bundler.require :test

require 'test/unit'

require 'kayak'

def load_fixture(filename)
  File.read(File.expand_path('../fixtures/' + filename, __FILE__))
end

def stub_valid_session
  stub_request(:get, "http://api.kayak.com/k/ident/apisession?token=token123").
    to_return(:status => 200, :body => <<-BODY, :headers => {})
      <?xml version="1.0"?>
      <ident>
        <uid>123123</uid>
        <sid>blablabla</sid>
        <token>cool_token</token>
        <error></error>
      </ident>
  BODY
end

