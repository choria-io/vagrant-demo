module MCollective
  module Util
    module Service
      class Base
        attr_accessor :service, :options

        # Base Service provider object will be created with the service
        # name and the pluginconf options as a hash.
        #
        # Example:
        #  plugin.service.puppet.hasstatus = true
        #  plugin.service.puppet.hasrestart = true
        #
        #  will pass an options hash to the provider object
        #
        #  {:hasstatus  => "true",
        #   :hasrestart => "true"}
        #
        def initialize(service, options)
          @service = service
          @options = options
        end

        # Providers extending the Base class should implement the
        # start method which is expected to start a stopped service
        # and return the results as a hash with an expected :status
        # key and an optional :msg key.
        #
        # Examples:
        #   return {:status => 'running'}
        #   return {:status => 'running', :msg => 'Service is already running'}
        #
        # The first example will set the reply status to 'running'.
        # The second example will cause the reply to fail, but the value of
        # reply[:status] will still be set correctly.
        def start
          raise "error. %s Does not implement #start" % self.class.to_s
        end

        # Providers extending the Base class should implement the
        # stop method which is expected to stop a running service
        # and return the results as a hash with an expected :status
        # key and an optional :msg key.
        #
        # Examples:
        #   return {:status => 'stopped'}
        #   return {:status => 'stopped', :msg => 'Service is already stopped'}
        #
        # The first example will set the reply status to 'stopped'.
        # The second example will cause the reply to fail, but the value of
        # reply[:status] will still be set correctly.
        def stop
          raise "error. %s Does not implement #stop" % self.class.to_s
        end

        # Providers extending the Base class should implement the
        # restart method which is expected to restart a running or
        # stopped service and return the status as 'running' or
        # 'stopped'
        def restart
          raise "error. %s Does not implement #restart" % self.class.to_s
        end

        # Providers extending the Base class should implement the
        # status method which is expected to return the current
        # run status of the service as 'stopped' or 'running'
        def status
          raise "error. %s Does not implement #status" % self.class.to_s
        end
      end
    end
  end
end
