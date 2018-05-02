require 'open3'

module MCollective
  module Util
    module Service
      class ServiceService<Base
        def start
          status = service_command('start')
          ret = status.success? ? 'running' : 'stopped'
          return {status: ret}
        end

        def stop
          status = service_command('stop')
          ret = status.success? ? 'stopped' : 'running'
          return {status: ret}
        end

        def restart
          status = service_command('restart')
          return 'running' if status.success?
          return 'stopped'
        end

        def status
          status = service_command('status')
          return 'running' if status.success?
          return 'stopped'
        end

        private
        def service_command(cmd)
          servicecmd = @options[:servicecmd] || '/sbin/service'
          _,status = Open3.capture2e(servicecmd,@service,cmd)
          status
        end
      end
    end
  end
end
