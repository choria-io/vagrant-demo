module MCollective
  module Util
    class ActionPolicy
      attr_accessor :config, :allow_unconfigured, :configdir, :agent, :caller_id
      attr_accessor :action, :groups, :enable_default, :default_name

      def self.authorize(request)
        ActionPolicy.new(request).authorize_request
      end

      def initialize(request)
        @config = Config.instance
        @agent = request.agent
        @caller_id = request.caller
        @action = request.action
        @allow_unconfigured = !!(config.pluginconf.fetch('actionpolicy.allow_unconfigured', 'n') =~ /^1|y/i)
        @enable_default = !!(config.pluginconf.fetch('actionpolicy.enable_default', 'n') =~ /^1|y/i)
        @default_name = config.pluginconf.fetch('actionpolicy.default_name', 'default')
        @configdir = @config.configdir
        @groups = {}
      end

      # Performs request authorization
      #
      # @return [Boolean]
      def authorize_request
        # Lookup the policy file. If none exists and @allow_unconfigured
        # is false the request gets denied.
        policy_file = lookup_policy_file

        # No policy file exists and allow_unconfigured is false
        if !policy_file && !allow_unconfigured
          deny('Could not load any valid policy files. Denying based on allow_unconfigured: %s' % allow_unconfigured)
        # No policy exists but allow_unconfigured is true
        elsif !(policy_file) && allow_unconfigured
          Log.debug('Could not load any valid policy files. Allowing based on allow_unconfigured: %s' % allow_unconfigured)
          return true
        end

        parse_group_file(lookup_groups_file)

        # A policy file exists
        parse_policy_file(policy_file)
      end

      # Parse and validate the policy file
      #
      # @param policy_file [String] path to the policy file
      # @return [Boolean]
      # @raize [RPCAborted] when the request does not pass the policy
      def parse_policy_file(policy_file)
        Log.debug('Parsing policyfile for %s: %s' % [agent, policy_file])
        allow = allow_unconfigured

        File.read(policy_file).each_line do |line|
          next if line =~ /^(#.*|\s*)$/

          if line =~ /^policy\s+default\s+(\w+)/
            if $1 == 'allow'
              allow = true
            else
              allow = false
            end
          elsif line =~ /^(allow|deny)\t+(.+?)\t+(.+?)\t+(.+?)(\t+(.+?))*$/
            if check_policy($2, $3, $4, $6)
              if $1 == 'allow'
                return true
              else
                deny("Denying based on explicit 'deny' policy rule in policyfile: %s" % File.basename(policy_file))
              end
            end
          else
            Log.warn("Cannot parse policy %s line: %s" % [policy_file, line])
          end
        end

        allow || deny("Denying based on default policy in %s" % File.basename(policy_file))
      end

      # Parses the group file into the `@groups` memory structure
      #
      # @param group_file [String] path to the groups file
      # @return [Hash] parsed groups
      def parse_group_file(group_file)
        return unless group_file
        return unless File.exist?(group_file)

        unless File.readable?(group_file)
          Log.warn("The group file %s exist but it is not readable" % group_file)
          return
        end

        Log.debug("Parsing groups file %s" % group_file)

        File.read(group_file).each_line do |line|
          next if line =~ /^(#.*|\s*)$/

          parts = line.chomp.split

          if parts[0] =~ /^([\w\.\-]+)$/
            next if parts[1..-1].empty?

            groups[ parts[0] ] = parts[1..-1]
          else
            Log.warn("Group file line '%s' is not in the expected format of 'group_name caller_id caller_id caller_id'" % line.chomp)
          end
        end

        groups
      end

      # Determines if any of the groups have the caller in them
      #
      # @param groups [String,nil] space seperated list of groups
      # @return [Boolean]
      def caller_in_groups?(group_names)
        return false unless group_names

        group_names.to_s.split.select do |group|
          next unless group =~ /^([\w\.\-]+)$/

          groups.fetch(group, []).include?(caller_id)
        end.any?
      end

      # Determine if the caller is any of the callerids
      #
      # @param caller_ids [String] space seperated list of caller ids
      # @return [Boolean]
      def caller_in_callerids?(caller_ids)
        return false unless caller_ids

        caller_ids.to_s.include?(caller_id)
      end

      def action_in_actions?(actions)
        actions.split.include?(action)
      end

      # Check if a request made by a caller matches the state defined in the policy
      #
      # @param rpccaller [String] the rpccaller as per the policy line
      # @param action [String] the actions as per the policy line
      # @param facts [String] the facts as per the policy line
      # @param classes [String] the facts as per the policy line
      # @return [Boolean]
      def check_policy(rpccaller, actions, facts, classes)
        # If we have a wildcard caller or the caller matches our policy line
        # then continue else skip this policy line
        return false unless rpccaller == '*' || caller_in_callerids?(rpccaller) || caller_in_groups?(rpccaller)

        # If we have a wildcard actions list or the request action is in the list
        # of actions in the policy line continue, else skip this policy line
        return false unless actions == '*' || action_in_actions?(actions)

        return parse_facts(facts) && parse_classes(classes) if classes

        parse_compound(facts)
      end

      # Parses and validates the facts from a policy line
      #
      # @param facts [String] facts as per the policy line
      # @return [Boolean]
      def parse_facts(facts)
        return true if facts == '*'

        if is_compound?(facts)
          return parse_compound(facts)
        else
          facts.split.each do |fact|
            return false unless lookup_fact(fact)
          end
        end

        true
      end

      # Parses and validates the classes from the policy line
      #
      # @param classes [String] classes as per the policy line
      # @return [Boolean]
      def parse_classes(classes)
        return true if classes == '*'

        if is_compound?(classes)
          return parse_compound(classes)
        else
          classes.split.each do |klass|
            return false unless lookup_class(klass)
          end
        end

        true
      end

      # Parses and validates a fact from the policy line
      #
      # @param fact [String] a standard fact filter format fact
      # @return [Boolean]
      def lookup_fact(fact)
        if fact =~ /(.+)(<|>|=|<=|>=)(.+)/
          lv = $1
          sym = $2
          rv = $3

          sym = '==' if sym == '='
          return eval("'#{Util.get_fact(lv)}'#{sym}'#{rv}'")
        else
          Log.warn("Class found where fact was expected")
          return false
        end
      end

      # Parses a class expression and validates it
      #
      # @param klass [String] class name to lookup and validate
      # @return [Boolean]
      def lookup_class(klass)
        if klass =~ /(.+)(<|>|=|<=|>=)(.+)/
          Log.warn("Fact found where class was expected")
          return false
        else
          return Util.has_cf_class?(klass)
        end
      end

      # Looks up and validates either a class or a fact
      #
      # @param token [String] either a fact in fact filter format or a class
      # @return [Boolean]
      def lookup(token)
        if token =~ /(.+)(<|>|=|<=|>=)(.+)/
          return lookup_fact(token)
        else
          return lookup_class(token)
        end
      end

      # Determines full path to the policy file
      #
      # Here we lookup the full path of the policy file. If the policyfile
      # does not exist, we check to see if a default file was set and
      # determine its full path. If no default file exists, or default was
      # not specified, we return false.
      #
      # @return [String,Boolean] full file path else false
      def lookup_policy_file
        policy_file = File.join(@configdir, "policies", "#{agent}.policy")

        Log.debug("Looking for policy in #{policy_file}")

        return policy_file if File.exist?(policy_file)

        if enable_default
          default_file = File.join(configdir, "policies", "#{default_name}.policy")

          Log.debug("Initial lookup failed: looking for policy in #{default_file}")

          return default_file if File.exist?(default_file)
        end

        Log.debug('Could not find any policy files.')

        false
      end


      # Determines full path to the groups file
      #
      # @return [String] path to the file
      def lookup_groups_file
        File.join(configdir, "policies", "groups")
      end

      # Evalute a compound statement and return its truth value
      #
      # @param statement [String] a standard compound filter string
      # @return [Boolean]
      def eval_statement(statement)
        token_type = statement.keys.first
        token_value = statement.values.first

        return token_value if (token_type != 'statement' && token_type != 'fstatement')

        if token_type == 'statement'
            return lookup(token_value)
        elsif token_type == 'fstatement'
          begin
            return Matcher.eval_compound_fstatement(token_value)
          rescue => e
            Log.warn("Could not call Data function in policy file: #{e}")
            return false
          end
        end
      end

      # Determines if a string is a compound filter
      #
      # @param list [String] a standard compound filter string
      # @return [Boolean]
      def is_compound?(list)
        list.split.each do |token|
          if token =~ /^!|^not$|^or$|^and$|\(.+\)/
            return true
          end
        end

        false
      end

      # Parse and evaluate a compound filter string
      #
      # @param list [String] compound filter
      # @return [Boolean]
      def parse_compound(list)
        stack = Matcher.create_compound_callstack(list)

        begin
          stack.map!{ |item| eval_statement(item) }
        rescue => e
          Log.debug(e.to_s)
          return false
        end

        eval(stack.join(' '))
      end

      # Log and raise an appropriate error on deny
      #
      # @param logline [String] line to log in the log file
      # @raise [RPCAborted] standard non specific failure error
      def deny(logline)
        Log.debug(logline)

        raise(RPCAborted, 'You are not authorized to call this agent or action.')
      end
    end
  end
end
