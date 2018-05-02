module MCollective
  module Agent
    class Service<RPC::Agent

      action 'stop' do
        stop_result = Service.do_service_action('stop', request[:service])

        if stop_result[:msg]
          reply[:status] = stop_result[:status]
          reply.fail! stop_result[:msg]
        else
          reply[:status] = stop_result[:status]
        end
      end

      action 'start' do
        start_result = Service.do_service_action('start', request[:service])

        if start_result[:msg]
          reply[:status] = start_result[:status]
          reply.fail! start_result[:msg]
        else
          reply[:status] = start_result[:status]
        end
      end

      action 'restart' do
        reply[:status] = Service.do_service_action('restart', request[:service])
      end

      action 'status' do
        reply[:status] = Service.do_service_action('status', request[:service])
      end

      # Loads service provider from config, calls the provider specific action
      # and returns the service status.
      def self.do_service_action(action, service)
        @config = Config.instance

        # Serivice provider defaults to puppet
        provider = @config.pluginconf.fetch('service.provider', 'puppet')
        provider_options = {}

        # Get the provider specific config options from pluginconf
        @config.pluginconf.each do |k, v|
          if k =~ /service\.#{provider}/
            provider_options[k.split('.').last.to_sym] = v
          end
        end

        begin
          Log.debug("Loading Service Provider: %s" % provider)
          provider = "%sService" % provider.capitalize
          PluginManager.loadclass("MCollective::Util::Service::Base")
          PluginManager.loadclass("MCollective::Util::Service::#{provider}")

          svc = Util::Service.const_get(provider).new(service, provider_options)
          Log.debug("Calling %s for service %s" % [action, service])
          return svc.send(action)

        rescue LoadError => e
          raise "Cannot load service provider implementation: %s: %s" % [provider, e.to_s]
        end
      end
    end
  end
end

# vi:tabstop=2:expandtab:ai:filetype=ruby
