module MCollective
  module Util
    module Package
      class YumPackage < Base
        def install
          call_action(:install)
        end

        def update
          call_action(:update)
        end

        def uninstall
          call_action(:remove)
        end

        # Status returns a hash of package properties
        def status
          call_action(:status)
        end

        def search
          call_action(:search)
        end

        # Calls and cleans up the yum provider
        def call_action(action)
          require "json"
          yumhelper = File::join(File::dirname(__FILE__), "yumHelper.py")
          raise "Cannot find yumHelper.py" unless File.exists?(yumhelper)
          result = {:exitcode => nil,
                    :output => ""}

          name = @package
          opts = @options
          cmd = Shell.new("#{yumhelper} --#{action} #{name}", :stdout => result[:output])
          cmd.runcommand
          result[:exitcode] = cmd.status.exitstatus

          raise "yumHelper.py failed, exit code was #{result[:exitcode]}" unless result[:exitcode] == 0
          r = JSON.parse(result[:output])
          r = Hash[r.map{|(k,v)| [k.to_sym,v]}]
          if r[:status].is_a?(Hash)
            r[:status] = Hash[r[:status].map{|(k,v)| [k.to_sym,v]}]
          end
          r
        end
      end
    end
  end
end
