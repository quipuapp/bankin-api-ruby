$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'webmock/rspec'
require "bankin"

def response_json(filename)
  path = File.join('spec', 'responses', "#{filename}.json")
  File.read(path)
end

def configure_bankin
  Bankin.configure do |config|
    config.client_id = 'client-id',
    config.client_secret = 'client-secret'
  end
end
