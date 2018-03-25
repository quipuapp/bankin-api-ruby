module Bankin
  class Resource
    def initialize(data, token = nil)
      @token = token
      generate_attr_readers
      set_data(data)
    end

    def fields
      self.class.fields
    end

    def resources
      self.class.resources
    end

    def collections
      self.class.collections
    end

    private

    def generate_attr_readers
      fields.each do |field|
        define_singleton_method(field) do
          load_data! if instance_variable_get("@#{field}").nil?
          instance_variable_get("@#{field}")
        end
      end

      (resources + collections).each do |resource|
        define_singleton_method(resource[:name]) do
          load_data! if instance_variable_get("@#{resource[:name]}").nil?
          instance_variable_get("@#{resource[:name]}")
        end
      end
    end

    def set_data(data)
      fields.each do |field|
        next unless data.key?(field.to_s)
        instance_variable_set("@#{field}", data[field.to_s])
      end

      resources.each do |resource|
        next unless data.key?(resource[:name].to_s)
        klass = Object.const_get("Bankin::#{resource[:klass]}")
        instance_variable_set("@#{resource[:name]}", klass.new(data[resource[:name].to_s], @token))
      end

      collections.each do |collection|
        next unless data[collection[:name].to_s]
        klass = Object.const_get("Bankin::#{collection[:klass]}")
        arr = data[collection[:name].to_s].map { |item| klass.new(item, @token) }
        instance_variable_set("@#{collection[:name]}", arr)
        instance_variable_set("@#{collection[:name]}_ids", arr.map(&:id))
      end
    end

    def load_data!
      return if @loaded
      response = Bankin.api_call(:get, @resource_uri, {}, @token)
      set_data(response)
      @loaded = true
    end

    class << self
      def fields
        @fields || [:resource_type, :resource_uri]
      end

      def resources
        @resources || []
      end

      def collections
        @collections || []
      end

      def auth_delegate(name, options)
        define_method(name) do |*args|
          klass = Object.const_get("Bankin::#{options[:class]}")
          klass.send(options[:method], self.token, *args)
        end
      end

      def has_fields(*new_fields)
        @fields = (fields + new_fields).uniq
      end

      def has_resource(name, klass)
        @resources = resources << { name: name, klass: klass }
      end

      def has_collection(name, klass)
        @collections = collections << { name: name, klass: klass }
        attr_reader :"#{name}_ids"
      end
    end
  end
end
