module Docker
  class Node

    attr_accessor :connection_string, :options

    def initialize(options = {}); end

    def client
      raise UnknownConnectionType, 'Missing Connection String' if connection_string.nil?
      Docker::Client.new(connection_string, options)
    end

  end
end
