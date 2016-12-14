module Bankin
  class Account < Resource
    RESOURCE_PATH = '/v2/accounts'

    has_fields :id, :name, :balance, :currency_code, :status, :type, :last_refresh_date

    has_resource :bank, 'Bank'
    has_resource :item, 'Item'

    def self.list(token, options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options, token)
      Collection.new(response, self, token)
    end

    def self.get(token, id)
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/#{id}", {}, token)
      new(response, token)
    end
  end
end
