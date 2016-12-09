module Bankin
  class Item < Resource
    RESOURCE_PATH = '/v2/items'

    has_fields :id, :status

    has_resource :bank, 'Bank'
    has_collection :accounts, 'Account'

    def delete
      Bankin.api_call(:delete, resource_uri, {}, @user.token)
    end

    def refresh
      Bankin.api_call(:post, "#{resource_uri}/refresh", {}, @user.token)
    end

    def get_status
      Bankin.api_call(:get, "#{resource_uri}/refresh/status", {}, @user.token)
    end

    def self.connect_url(user, bank_id, redirect_url = nil)
      url_parts = [
        Bankin.const_get(:BASE_URL),
        RESOURCE_PATH,
        "/connect?client_id=#{Bankin.configuration.client_id}",
        "&bank_id=#{bank_id}",
        "&access_token=#{user.token}"
      ]
      url_parts << "&redirect_url=#{redirect_url}" if redirect_url
      url_parts.join
    end

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
