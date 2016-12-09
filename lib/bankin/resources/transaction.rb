module Bankin
  class Transaction < Resource
    RESOURCE_PATH = '/v2/transactions'

    has_fields :id, :description, :raw_description, :amount, :currency_code,
      :date, :updated_at, :is_deleted

    has_resource :account, 'Account'

    def self.list(user, options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options, user.token)
      Collection.new(response, self, user)
    end

    def self.list_updated(user, options = {})
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/updated", options, user.token)
      Collection.new(response, self, user)
    end

    def self.get(user, id)
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/#{id}", {}, user.token)
      new(response, user)
    end
  end
end
