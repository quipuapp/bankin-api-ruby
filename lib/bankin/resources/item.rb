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

    def refresh_status
      Bankin.api_call(:get, "#{resource_uri}/refresh/status", {}, @token)
    end

    def edit_url
      Bankin.api_call(
        :get,
        "/v2/connect/items/edit/url",
        { item_id: id },
        @token
      )['redirect_url']
    end

    def fill_in_otp_url
      Bankin.api_call(
        :get,
        "/v2/connect/items/sync?item_id=#{id}",
        {},
        @token
      )['redirect_url']
    end

    def self.add_url(token, redirect_url, params)
      Bankin.api_call(
        :get,
        "/v2/connect/items/add/url",
        params.merge(redirect_url: redirect_url),
        token
      )['redirect_url']
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
