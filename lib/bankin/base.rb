require 'rest-client'
require 'json'

module Bankin
  BASE_URL = 'https://sync.bankin.com'
  API_VERSION = '2016-01-18'

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def api_call(method, path, params = {}, token = nil)
      url = Bankin.const_get(:BASE_URL) + path

      request_params = {
        method: method,
        url: url,
        headers: {
          'Bankin-Version': Bankin.const_get(:API_VERSION),
          params: {
            client_id: Bankin.configuration.client_id,
            client_secret: Bankin.configuration.client_secret
          }.merge(params)
        }
      }
      request_params[:headers][:Authorization] = "Bearer #{token}" if token

      begin
        p 'API CALL...'
        response = RestClient::Request.execute(request_params)
        return {} if response.empty?
        data = JSON.parse(response)
        return data
      rescue StandardError => e
        response = JSON.parse(e.response)
        raise Error.new(response['type'], response['message'])
      end
    end
  end
end
