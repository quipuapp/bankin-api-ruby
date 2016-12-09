module Bankin
  class Bank < Resource
    RESOURCE_PATH = '/v2/banks'

    has_fields :id, :name, :automatic_refresh, :country_code

    def self.list(options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options)
      Collection.new(response, self)
    end

    def self.get(id)
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/#{id}")
      new(response)
    end
  end
end
