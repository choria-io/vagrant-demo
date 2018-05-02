module MCollective
  module Util
    module Package
      class Base
        attr_accessor :package, :options

        # Base Package provider object will be created with the
        # package name and the pluginconf options as a hash.
        #
        # Example:
        #   plugin.package.puppet.allowcdrom = true
        #
        #   will pass an options hash to the provider object
        #
        #   {:allowcdrom => "true}
        def initialize(package, options)
          @package = package
          @options = options
        end

        # Providers extending the Base class should implement the install
        # method which is expected to install an uninstalled package and
        # return the results as a hash with expected :status and :output
        # keys and an optional :msg key. The :status key should be a hash
        # containing the outputs described in the Status action of the package
        # DDL. Including the :msg key will cause an agent action to fail with
        # :msg as the failure message.
        #
        # Examples:
        #   return {:status => {'installed'}}
        #   return {:status => {:arch => 'x86',
        #                       :ensure => 'xx-xx-xx',
        #                       :epoch => '123456',
        #                       :version => 'xx-xx-xx',
        #                       :provider => 'yum',
        #                       :release => '1'},
        #          :msg    => 'Package is already installed'}
        #
        #
        # The first example will set the reply status to 'installed'.
        # The second example will cause the the reply to fail, but the
        # value of reply[:status] will be set correctly.
        def install
          raise "error. %s does not implement #install" % self.class
        end

        # Providers extending the Base class should implement the uninstall
        # method which is expected to uninstall an installed package and
        # return the results as a hash with expected :status and :output
        # keys and an optional :msg key. The :status key should be a hash
        # containing the outputs described in the Status action of the package
        # DDL. Including the :msg key will cause an agent action to fail with
        # :msg as the failure message.
        #
        # Examples:
        #   return {:status => {'installed'}}
        #   return {:status => {:arch => 'x86',
        #                       :ensure => 'xx-xx-xx',
        #                       :epoch => '123456',
        #                       :version => 'xx-xx-xx',
        #                       :provider => 'yum',
        #                       :release => '1'},
        #          :msg    => 'Package is not installed'}
        #
        #
        # The first example will set the reply status to 'installed'.
        # The second example will cause the the reply to fail, but the
        # value of reply[:status] will be set correctly.
        def uninstall
          raise "error. %s does not implement #uninstall" % self.class
        end

        # Providers extending the Base class should implement the purge
        # method which is expected to purge an installed package and
        # return the results as a hash with expected :status and :output
        # keys and an optional :msg key. The :status key should be a hash
        # containing the outputs described in the Status action of the package
        # DDL. Including the :msg key will cause an agent action to fail with
        # :msg as the failure message.
        #
        # Examples:
        #   return {:status => {'installed'}}
        #   return {:status => {:arch => 'x86',
        #                       :ensure => 'xx-xx-xx',
        #                       :epoch => '123456',
        #                       :version => 'xx-xx-xx',
        #                       :provider => 'yum',
        #                       :release => '1'},
        #          :msg    => 'Package is not installed'}
        #
        #
        # The first example will set the reply status to 'installed'.
        # The second example will cause the the reply to fail, but the
        # value of reply[:status] will be set correctly.
        def purge
          raise "error. %s does not implement #purge" % self.class
        end

        # Providers extending the Base class should implement the update
        # method which is expected to upinstall an installed package and
        # return the results as a hash with expected :status and :output
        # keys and an optional :msg key. The :status key should be a hash
        # containing the outputs described in the Status action of the package
        # DDL. Including the :msg key will cause an agent action to fail with
        # :msg as the failure message.
        #
        # Examples:
        #   return {:status => {'installed'}}
        #   return {:status => {:arch => 'x86',
        #                       :ensure => 'xx-xx-xx',
        #                       :epoch => '123456',
        #                       :version => 'xx-xx-xx',
        #                       :provider => 'yum',
        #                       :release => '1'},
        #          :msg    => 'Package is not installed'}
        #
        #
        # The first example will set the reply status to 'installed'.
        # The second example will cause the the reply to fail, but the
        # value of reply[:status] will be set correctly.
        def update
          raise "error. %s does not implement #update" % self.class
        end

        # Providers extending the Base class should implement the status
        # method which is expected to return the status of a pacakge as
        # a hash containing the outputs described in the Status action of
        # the packa DDL.
        #
        # Example:
        #   return {:arch => 'x86',
        #           :ensure => 'xx-xx-xx',
        #           :epoch => '123456',
        #           :version => 'xx-xx-xx',
        #           :provider => 'yum',
        #           :release => '1'}
        def status
          raise "error. %s does not implement #status" % self.class
        end
      end
    end
  end
end
