module MCollective
  module Data
    class Package_data<Base
      activate_when{PluginManager['package_agent']}

      query do |package|
        begin
          val = {}
          Agent::Package.do_pkg_action(package, :status, val)
          result[:status] = val[:ensure]
          # If the package is either 'absent' or 'purged' report it as not installed
          result[:installed] = ! ["absent", "purged"].include?(val[:ensure])
        rescue => e
          Log.warn("Could not get status for package #{package}: #{e.to_s}")
        end
      end
    end
  end
end
