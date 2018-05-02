module MCollective
  module Agent
    class Process < RPC::Agent
      activate_when do
        begin
          require "sys/proctable"
          true
        rescue
          Log.warn("Cannot load sys/proctable gem. Process_agent plugin requires this gem to be installed")
          false
        end
      end

      action "list" do
        pattern = request[:pattern] || "."
        zombies = request[:just_zombies] || false
        user    = request[:user] || false

        # force all the data into strings for keys for long term JSON on the wire compatability
        reply[:pslist] = JSON.parse(JSON.dump(get_proc_list(pattern, zombies, user)))
      end

      private

      def ps_to_hash(ps)
        require "etc"
        result = {}

        ps.each_pair do |k, v|
          if k == :uid
            begin
              result[:username] = Etc.getpwuid(v).name
            rescue
              Log.debug("Could not get username for %s: %s" % [v, $!])
              result[:username] = v
            end
          end

          result[k] = v
        end

        result
      end

      def get_uid(user)
        Etc.getpwnam(user).uid
      rescue
        Log.debug("Could not get uid for user: #{user}")
        false
      end

      def get_user_proc_list(pattern, zombies, user)
        if uid = get_uid(user)
          result = Sys::ProcTable.ps.map do |ps|
            ret = nil
            if ps["cmdline"] =~ /#{pattern}/ && ps["uid"] == uid
              ret = ps_to_hash(ps)
              ret = ps_to_hash(ps) if ps[:state] == "Z" && zombies
            end
            ret
          end
          result.compact
        else
          []
        end
      end

      def get_all_proc_list(pattern, zombies)
        result = Sys::ProcTable.ps.map do |ps|
          ret = nil
          if ps["cmdline"] =~ /#{pattern}/
            ret = ps_to_hash(ps)
            ret = ps_to_hash(ps) if ps[:state] == "Z" && zombies
          end
          ret
        end
        result.compact
      end

      def get_proc_list(pattern, zombies, user)
        return get_user_proc_list(pattern, zombies, user) if user

        get_all_proc_list(pattern, zombies)
      end
    end
  end
end
