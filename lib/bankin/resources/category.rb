module Bankin
  class Category < Resource
    RESOURCE_PATH = '/v2/categories'

    has_fields :id, :name

    has_resource :parent, 'Category'

    def self.list(options = {})
      response = Bankin.api_call(:get, RESOURCE_PATH, options)
      Collection.new(response, self)
    end

    def self.get(id)
      response = Bankin.api_call(:get, "#{RESOURCE_PATH}/#{id}", {})
      new(response)
    end
  end
end
