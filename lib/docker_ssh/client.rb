module DockerSSH
  class Client

    attr_accessor :conn_method, :path, :options, :port

    # Docker Connection:
    # connection_string: ssh://192.168.29.1:22
    # conn_method: tcp or ssh
    # path: full path,including port, to host.
    # options = {:key => "path"}
    def initialize(connection_string, opts = {})
      self.conn_method = connection_string.split('://').first
      self.path = connection_string.split('://').last.split(':').first
      port = connection_string.split('://').last.split(':').last
      if port.nil?
        port = conn_method == 'ssh' ? 22 : 2375
      end
      self.port = port
      self.options = opts
    end

    # TODO: Attempt to discover the API version, as this is how we determine if the API is availble.
    def version
      1
    end

    # Run arbitrary commands on a host or tcp endpoint.
    def exec!(command = nil)
      case conn_method
      when 'ssh'
        ssh(command)
      when 'tcp'
        tcp(command)
      else
        raise UnknownConnectionType, "Unknown Connection Method. Valid options are 'ssh://' and 'tcp://'"
      end
    end

    private

    def ssh(command)
      raise MissingParameter, 'Missing SSH Key' if options[:key].nil?
      timeout = command.nil? ? 10 : 300
      begin
        Timeout.timeout(timeout) do
          begin
            ssh = Net::SSH.start(path, 'root', keys: [options[:key]], user_known_hosts_file: '/dev/null', auth_methods: ['publickey'], port: port)
          rescue Net::SSH::AuthenticationFailed
            raise AuthenticationFailed, 'SSH Authentication Failure'
          rescue Errno::ECONNREFUSED
            # TODO: Handle connection refused differently?
            raise ConnectionFailed, 'Unable to connect'
          rescue
            raise ConnectionFailed, 'Unable to connect'
          end
          rsp = ''
          if command
            ssh.exec!(command) do |_, _, line|
              rsp += line
            end
          end
          ssh.close()
          # Try to capture non-json responses. 'Error' may appear in text somewhere else, so can't just look for that. Valid response will have " {" on [1] of the split.
          if rsp.split("\n")[1] =~ /Error/
            # Unknown containers will have the response:
            # '[]\nError: No such image or container: test\n'
            if rsp.split("\n")[1]
              raise UnknownContainer, rsp.split("\n")[1]
            else
              raise CommandFailed, rsp
            end
          else
            # First try to parse as JSON, but fallback to plaintext.
            begin
              return JSON.parse(rsp, quirks_mode: true, allow_nan: true)
            rescue
              return rsp
            end
          end
        end
      rescue Timeout::Error
        raise ConnectionTimeout, 'SSH Timeout'
      end
    end

    def tcp(command)

    end

  end
end
