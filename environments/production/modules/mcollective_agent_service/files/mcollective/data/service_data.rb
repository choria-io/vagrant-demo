module MCollective
  module Data
    class Service_data<Base
      activate_when{PluginManager['service_agent']}

      query do |service|
        begin
          result[:status] = Agent::Service.do_service_action('status', service)
        rescue => e
          Log.warn("Could not get status for service #{service}: #{e.to_s}")
        end
      end
    end
  end
end
