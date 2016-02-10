## Docker Container
#
# Params:
# - container_id: Either actual docker ID, or the unique name
# - connection_string: ssh://192.168.29.22:22 or tcp://192.168.29.66:2075. Default ports can be omitted
# - image_url: string
# - options:
# {
#   :settings => {
#     :env => [], :volume => [], :args => [], :port_map => [{'ext' => 0, 'int' => 0}]
#   },
#   :node => {
#     :key => ''
#   }
# }
#
# TODO: Make sure linked resources are up and running.
# - dependents: [<container-id>] -- an array of container id's. This will make sure they exist before start and create
# - required_by: [<container_id>] -- an array of container id's. This will make sure containers that require this one are rebooted.
#
#
# Docker::Container.new('registry', 'ssh://192.168.29.66', {node: {key: "/home/vagrant/.ssh/id_rsa"}})
module Docker
  class Container

    attr_accessor :container_id,
                  :connection_string,
                  :image_url,
                  :options

    def initialize(container_id, connection_string, options = {})
      self.container_id = container_id
      self.connection_string = connection_string
      self.options = options
      unless options.nil?
        self.image_url = options[:image_url]
      end
    end

    def image
      if image_url
        image_url
      elsif connection_string
        # Retrieve it
      else
        nil
      end
    end

    def info
      case client.conn_method
      when "ssh"
        client.perform!("docker inspect #{container_id}")
      when "tcp"
        #
      end
    end

    def create!

    end

    def client
      raise MissingConnectionString, 'No method of contacting node.' if connection_string.nil?
      Docker::Client.new(connection_string, options[:node])
    end

  end
end
