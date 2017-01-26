module DockerSSH
  class Network

    attr_accessor :id,
                  :subnet,
                  :attachable,
                  :encrypted,
                  :connection_string,
                  :options

    def initialize(connection_string, options = {})
      self.connection_string = connection_string
      self.options = options
      self.attachable = true
      self.encrypted = false
    end

    def create!
      raise MissingParameter, 'Missing Subnet' if self.subnet.nil?
      raise MissingParameter, 'Missing Network ID' if self.id.nil?
      cmd = ['docker network create']
      cmd << '--attachable' if self.attachable
      cmd << '--driver overlay'
      cmd << '--opt encrypted' if self.encrypted
      cmd << "--subnet=#{self.subnet}"
      cmd << self.id
      command = cmd.join(' ')
      client.exec!(command)
    end

    def destroy!
      raise MissingParameter, 'Missing Network ID' if self.id.nil?
      client.exec!("docker network rm #{self.id}")
    end

    # List connected containers
    def containers
      raise MissingParameter, 'Missing Network ID' if self.id.nil?
      begin
        client.exec!("docker network inspect #{self.id} --format '{{json .Containers}}'")
      rescue
        {}
      else
        data = []
        result.each_key do |k|
          d = result[k]
          data[k['Name']] = {
            'ipv4' => d['IPv4Address'].split('/').first,
            'ipv6' => d['IPv6Address']
          }
        end
        data
      end
    end

    def client
      raise UnknownConnectionType, 'Missing Connection String' if connection_string.nil?
      DockerSSH::Client.new(connection_string, options)
    end

  end
end
