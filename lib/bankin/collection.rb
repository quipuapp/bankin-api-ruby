module Bankin
  class Collection < Array
    def initialize(response, item_class, token = nil)
      @item_class = item_class
      @token = token
      populate!(response, item_class)
    end

    def next_page?
      !@next_page_uri.nil?
    end

    def previous_page?
      !@previous_page_uri.nil?
    end

    def next_page!
      return unless next_page?
      response = Bankin.api_call(:get, @next_page_uri, {}, @token)
      populate!(response, @item_class)
      self
    end

    def load_all!
      while next_page? do
        next_page!
      end
      self
    end

    private

    def populate!(response, item_klass)
      response['resources'].each do |item|
        self << item_klass.new(item, @token)
      end

      set_pagination(response['pagination'])
    end

    def set_pagination(pagination_data)
      @next_page_uri = pagination_data['next_uri']
      @previous_page_uri = pagination_data['previous_uri']
    end
  end
end
