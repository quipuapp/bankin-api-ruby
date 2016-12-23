module Bankin
  class Item < Resource
    RESOURCE_PATH = '/v2/items'

    has_fields :id, :status

    has_resource :bank, 'Bank'
    has_collection :accounts, 'Account'

    def delete
      Bankin.api_call(:delete, resource_uri, {}, @token)
    end

    def refresh
      Bankin.api_call(:post, "#{resource_uri}/refresh", {}, @token)
    end

    def get_status
      Bankin.api_call(:get, "#{resource_uri}/refresh/status", {}, @token)
    end

    def edit_url(redirect_url = nil)
      url_parts = [
        Bankin.const_get(:BASE_URL),
        resource_uri,
        "/edit?client_id=#{Bankin.configuration.client_id}",
        "&access_token=#{@token}"
      ]
      url_parts << "&redirect_url=#{redirect_url}" if redirect_url
      url_parts.join
    end

    def self.connect_url(token, bank_id, redirect_url = nil)
      url_parts = [
        Bankin.const_get(:BASE_URL),
        RESOURCE_PATH,
        "/connect?client_id=#{Bankin.configuration.client_id}",
        "&bank_id=#{bank_id}",
        "&access_token=#{token}"
      ]
      url_parts << "&redirect_url=#{redirect_url}" if redirect_url
      url_parts.join
    end

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
