## Docker Container
#
# Params:
# - container_id: Either actual docker ID, or the unique name
# - connection_string: ssh://192.168.29.22:22 or tcp://192.168.29.66:2075. Default ports can be omitted
# - image_url: string
# - options: (Only used for .new())
# {
#   :settings => {
#     :env => [], :volumes => [], :args => [], :port_map => [[host, container]]
#   },
#   :node => {
#     :key => ''
#   }
# }
# options[:settings][{env,args}] = [[k,v]]
# options[:settings][{volumes,port_map}] = [[host,container]]
#
#
# - options: (Perstant throughout model. Created during init)
# {
#   :node => {
#     :key => ''
#   },
#   :runtime =>
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
                  :env,
                  :args,
                  :volumes,
                  :port_map,
                  :restart_policy,
                  :options

    def initialize(container_id, connection_string, options = {})
      self.container_id = container_id
      self.connection_string = connection_string
      self.options = options
      unless options.nil?
        self.image_url = options[:image_url]
        options.delete(:image_url) if options[:image_url]
        if options[:settings]
          self.env = options[:settings][:env]
          self.args = options[:settings][:args]
          self.restart_policy = options[:settings][:restart_policy]
          self.port_map = options[:settings][:port_map]
          self.volumes = options[:settings][:volumes]
          options.delete(:settings)
        end
      end
      if self.restart_policy.nil?
        self.restart_policy = "no"
      end
    end

    def start
      client.exec!("docker start #{container_id}")
    end

    def stop
      client.exec!("docker stop #{container_id}")
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
        client.exec!("docker inspect --type=container #{container_id}")
      when "tcp"
        #
      end
    end

    def logs
      response = client.exec!("docker logs --timestamps=true --tail=125 #{container_id}")
      log = []
      log << response.split("\n")
      return log.flatten
    end

    # Returns container uptime in human readable format.
    def status
      client.exec!("docker ps --filter 'name=#{container_id}' --format '{{.Status}}'")
    end

    ## Actions ####
    def create!(dry_run = false)
      false if created?
      if client.conn_method == 'ssh'
        commands = []
        commands << "docker run -d --name #{container_id}"
        unless restart_policy == 'no'
          commands << "--restart=#{restart_policy}"
        end
        if port_map
          port_map.each do |h,c|
            commands << "-p #{h}:#{c}"
          end
        end
        if env
          env.each do |k,v|
            commands << "-e #{k}=#{v}"
            #commands << %Q[-e #{k}="#{v}"]
          end
        end
        if volumes
          volumes.each do |h,c|
            commands << "-v #{h}:#{c}"
          end
        end
        if args
          args.each do |k,v|
            commands << "--#{k}=#{v}"
          end
        end
        commands << image_url
        cmd = commands.join(" ")
        dry_run ? cmd : client.exec!(cmd)
      else
        #
      end
    end

    def destroy
      client.exec!("docker rm #{container_id}")
    end

    ## END ACTIONS #####

    # Perform one-time exec action on a container. This will create & delete a container.
    def exec!(entrypoint, command, dry_run = false)
      false if self.image_url.nil?
      cmd = "docker run --rm --entrypoint #{entrypoint} #{self.image_url} #{command}"
      dry_run ? cmd : client.exec!(cmd)
    end

    def client
      raise MissingConnectionString, 'No method of contacting node.' if connection_string.nil?
      Docker::Client.new(connection_string, options[:node])
    end

    ## Helpers
    def created?
      !client.exec!("docker ps --filter 'name=#{container_id}' --format '{{.Status}}'").blank?
    end
    ## END Helpers

  end
end
