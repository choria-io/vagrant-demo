module MCollective
  module Util
    module Service
      class PuppetService<Base
        def stop
          if status == 'stopped'
            msg = "Could not stop '%s': Service is already stopped" % @service
          else
            service_provider.stop
          end

          {:status => properties, :msg => msg}
        end

        def start
          if status == 'running'
            msg = "Could not start '%s': Service is already running" % @service
          else
            service_provider.start
          end
          {:status => properties, :msg => msg}
        end

        def restart
          service_provider.restart
          properties
        end

        def status
          service_provider.status.to_s
        end

        private
        def service_provider
          require 'puppet'
          @svc ||= Puppet::Type.type(:service).new({:name => @service}.merge(@options)).provider
        end

        def properties
          sleep 0.5
          status
        end
      end
    end
  end
end
