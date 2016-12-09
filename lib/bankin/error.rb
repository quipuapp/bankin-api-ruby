module Bankin
  class Error < StandardError
    attr_reader :message, :type

    def initialize(type, message)
      @type = type
      @message = message
    end
  end
end
