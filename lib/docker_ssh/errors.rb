module DockerSSH
  class AuthenticationFailed < RuntimeError; end
  class ConnectionFailed < RuntimeError; end
  class ConnectionTimeout < RuntimeError; end
  class MissingParameter < RuntimeError; end
  class UnknownContainer < RuntimeError; end

  # Clients
  class MissingConnectionString < RuntimeError; end
  class UnknownConnectionType < RuntimeError; end
  class MissingSSHKey < RuntimeError; end
  class CommandFailed < RuntimeError; end

end
