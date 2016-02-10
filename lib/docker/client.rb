module Docker
  class Client

    attr_accessor :conn_method, :path, :options, :port

    # Docker Connection:
    # connection_string: ssh://192.168.29.1:22
    # conn_method: tcp or ssh
    # path: full path,including port, to host.
    # options = {:key => "path"}
    def initialize(connection_string, options = {})
      self.conn_method = connection_string.split("://").first
      self.path = connection_string.split("://").last.split(":").first
      port = connection_string.split("://").last.split(":").last
      if port.nil?
        port = conn_method == 'ssh' ? 22 : 2375
      end
      self.port = port
      self.options = options
    end

    def perform!(command = nil)
      case self.conn_method
      when "ssh"
        ssh(command)
      when "tcp"
        tcp(command)
      else
        raise UnknownConnectionType, "Unknown Connection Method. Valid options are 'ssh://' and 'tcp://'"
      end
    end

    private

    def ssh(command)
      raise MissingParameter, "Missing SSH Key." if options[:key].nil?
      timeout = command.nil? ? 10 : 300
      begin
        Timeout.timeout(timeout) do
          begin
            ssh = Net::SSH.start(path, "root", :keys => [options[:key]], :user_known_hosts_file => "/dev/null", :auth_methods => ['publickey'])
          rescue Net::SSH::AuthenticationFailed
            raise AuthenticationFailed, "SSH Authentication Failure"
          rescue Errno::ECONNREFUSED
            # TODO: Handle connection refused differently?
            raise ConnectionFailed, "Unable to connect"
          rescue
            raise ConnectionFailed, "Unable to connect"
          end
          rsp = ""
          if command
            ssh.exec!(command) do |ch, stream, line|
              rsp += line
            end
          end
          ssh.close()
          return rsp
        end
      rescue Timeout::Error
        raise ConnectionTimeout, "SSH Timeout"
      end
    end

  end
end
