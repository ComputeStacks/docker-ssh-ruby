module DockerSSH
  class Node

    attr_accessor :connection_string, :options

    def initialize(connection_string, options = {})
      self.connection_string = connection_string
      self.options = options
    end

    def client
      raise UnknownConnectionType, 'Missing Connection String' if connection_string.nil?
      DockerSSH::Client.new(connection_string, options)
    end

  end
end
