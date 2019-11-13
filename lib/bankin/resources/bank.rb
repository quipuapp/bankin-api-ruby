module Bankin
  class Bank < Resource
    RESOURCE_PATH = '/v2/banks'

    has_fields :id, :name, :automatic_refresh, :country_code

    def self.list(options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options)
      Collection.new(flatten_list(response), self)
    end

    def self.get(id)
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/#{id}")
      new(response)
    end

    private

    def self.flatten_list(response)
      response["resources"] = response["resources"].map do |country_banks|
        country_banks["parent_banks"].map do |entity_banks|
          entity_banks["banks"]
        end.flatten
      end.flatten

      response
    end
  end
end
