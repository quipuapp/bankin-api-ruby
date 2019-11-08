require 'rest-client'
require 'json'

module Bankin
  BASE_URL = 'https://sync.bankin.com'
  API_VERSION = '2018-06-15'
  RATELIMIT_FIELDS = %w(limit remaining reset)

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def rate_limits
      @rate_limits ||= Hash[RATELIMIT_FIELDS.map { |f| [f, nil] }]
    end

    def configure
      yield(configuration)
    end

    def api_call(method, path, params = {}, token = nil)
      url = Bankin.const_get(:BASE_URL) + path

      log_message("#{method.upcase} #{url}")
      params.each do |k, v|
        next if k =~ /password/

        log_message("* #{k}: #{v}")
      end

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
        response = RestClient::Request.execute(request_params)
        set_rate_limits(response.headers)

        return {} if response.empty?
        data = JSON.parse(response)
        return data
      rescue StandardError => e
        response = JSON.parse(e.response)
        raise Error.new(response['type'], response['message'])
      end
    end

    def set_rate_limits(headers)
      @rate_limits ||= {}

      RATELIMIT_FIELDS.each do |field|
        @rate_limits[field] = headers["ratelimit_#{field}".to_sym]
      end
    end

    def log_message(msg)
      return if msg.nil? || msg.empty?

      log_path = Bankin.configuration.log_path
      return if log_path.nil? || log_path.empty?

      Logger
        .new(log_path)
        .info(msg)
    end
  end
end
