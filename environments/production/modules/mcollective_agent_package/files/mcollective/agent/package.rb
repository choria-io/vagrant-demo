module MCollective
  module Agent
    class Package<RPC::Agent

      action 'install' do
        Package.do_pkg_action(request[:package], :install, reply, request[:version])
      end

      action 'update' do
        Package.do_pkg_action(request[:package], :update, reply)
      end

      action 'uninstall' do
        Package.do_pkg_action(request[:package], :uninstall, reply)
      end

      action 'purge' do
        Package.do_pkg_action(request[:package], :purge, reply)
      end

      action 'status' do
        Package.do_pkg_action(request[:package], :status, reply)
      end

      action 'count' do
        result = package_helper.count
        reply[:exitcode] = result[:exitcode]
        reply[:output] = result[:output]
      end

     action 'md5' do
        result = package_helper.md5
        reply[:exitcode] = result[:exitcode]
        reply[:output] = result[:output]
      end

      action 'yum_clean' do
        clean_mode = request[:mode] || @config.pluginconf.fetch('package.yum_clean_mode', 'all')
        result = package_helper.yum_clean(clean_mode)
        reply[:exitcode] = result[:exitcode]
        reply[:output] = result[:output]
      end

      action 'apt_update' do
        result = package_helper.apt_update
        reply[:exitcode] = result[:exitcode]
        reply[:output] = result[:output]
      end

      action 'checkupdates' do
        do_checkupdates_action('checkupdates')
      end

      action 'yum_checkupdates' do
        do_checkupdates_action('yum_checkupdates')
      end

      action 'apt_checkupdates' do
        do_checkupdates_action('apt_checkupdates')
      end

      # Identifies the configured package provider
      # Defaults to puppet
      def self.package_provider
        return Config.instance.pluginconf.fetch('package.provider', 'puppet')
      end

      # Loads both the base class that all providers should inherit from,
      # as well as the actual provider class that implements the install,
      # uninstall, purge, update and status methods.
      def self.load_provider_class(provider)
        provider = "%sPackage" % provider.capitalize
        Log.debug("Loading %s package provider" % provider)

        begin
          PluginManager.loadclass('MCollective::Util::Package::Base')
          PluginManager.loadclass("MCollective::Util::Package::#{provider}")
          Util::Package.const_get(provider)
        rescue => e
          Log.debug("Cannot load package provider class '%s': %s" % [provider, e.to_s])
          raise "Cannot load package provider class '%s': %s" % [provider, e.to_s]
        end
      end

      # Parses the plugin configuration for all configuration options
      # specific to package provider.
      # Configuration options are defined as:
      #
      #   plugin.package.my_provider.x = y
      #
      # which will then be returned as
      #
      #   {:x => 'y'}
      #
      def self.provider_options(provider, version = nil)
        provider_options = {}

        Config.instance.pluginconf.each do |k, v|
          if k =~ /package\.#{provider}/
            provider_options[k.split('.').last.to_sym] = v
          end
        end

        unless version.nil?
          provider_options[:ensure] = version
        end

        provider_options
      end

      # Loads the required package provider and calls the method that
      # corresponds to the supplied action. The third arugment is an
      # in-out variable used to update the reply values in the case of
      # agents, and the value hash in the case of data plugins.
      def self.do_pkg_action(package, action, reply, version=nil)
        provider = Package.load_provider_class(Package.package_provider).new(package, Package.provider_options(Package.package_provider, version))
        result = provider.send(action)

        if action == :status
          result.each do |k,v|
            reply[k] = v.to_s
          end
        else
          result[:status].each do |k,v|
            reply[k] = v.to_s
          end
        end

        raise result[:msg] if result[:msg]

        reply[:output] = result[:output].to_s if result[:output]
      end

      private
      # Calls the correct helper method corresponding to the supplied
      # action and updates the agents reply values.
      def do_checkupdates_action(action)
        result = package_helper.send(action)
        reply[:exitcode] = result[:exitcode]
        reply[:output] = result[:output]
        reply[:outdated_packages] = result[:outdated_packages]
        reply[:package_manager] = result[:package_manager]
      end

      # Loads and returns the package_helper class
      def package_helper
        PluginManager.loadclass('MCollective::Util::Package::PackageHelpers')
        Util::Package.const_get('PackageHelpers')
      end
    end
  end
end
