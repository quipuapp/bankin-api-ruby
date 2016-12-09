module Bankin
  class Account < Resource
    RESOURCE_PATH = '/v2/accounts'

    has_fields :id, :name, :balance, :currency_code, :status, :type, :updated_at

    has_resource :bank, 'Bank'
    has_resource :item, 'Item'

    def self.list(user, options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options, user.token)
      Collection.new(response, self, user)
    end

    def self.get(user, id)
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/#{id}", {}, user.token)
      new(response, user)
    end
  end
end
