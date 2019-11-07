module Bankin
  class User < Resource
    attr_accessor :token

    RESOURCE_PATH = '/v2/users'

    has_fields :uuid, :email

    auth_delegate :items, class: 'Item', method: :list
    auth_delegate :item, class: 'Item', method: :get
    auth_delegate :accounts, class: 'Account', method: :list
    auth_delegate :account, class: 'Account', method: :get
    auth_delegate :updated_transactions, class: 'Transaction', method: :list_updated
    auth_delegate :transactions, class: 'Transaction', method: :list
    auth_delegate :transaction, class: 'Transaction', method: :get

    def delete(password)
      Bankin.api_call(:delete, resource_uri, { password: password })
    end

    def add_item_url(redirect_url = nil, params = {})
      authenticate unless token.present?

      Item.add_url(token, redirect_url, params)
    end

    def item_connect_url(bank_id, redirect_url = nil)
      Item.connect_url(token, bank_id, redirect_url)
    end

    def self.list(options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options)
      Collection.new(response, self)
    end

    def self.delete_all
      Bankin.api_call(:delete, RESOURCE_PATH)
    end

    def self.create(email, password)
      response = Bankin.api_call(:post, RESOURCE_PATH,
        { email: email, password: password })
      new(response)
    end

    def self.authenticate(email, password)
      response = Bankin.api_call(:post, '/v2/authenticate',
        { email: email, password: password })
      user = new(response['user'])
      user.token = response['access_token']
      user
    end
  end
end
