module Bankin
  class Transaction < Resource
    RESOURCE_PATH = '/v2/transactions'

    has_fields :id, :description, :raw_description, :amount, :date,
      :updated_at, :currency_code, :is_deleted

    has_resource :account, 'Account'

    def self.list(token, options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options, token)
      Collection.new(response, self, token)
    end

    def self.list_updated(token, options = {})
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/updated", options, token)
      Collection.new(response, self, token)
    end

    def self.get(token, id)
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/#{id}", {}, token)
      new(response, token)
    end
  end
end
