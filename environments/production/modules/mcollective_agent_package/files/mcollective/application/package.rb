module MCollective
  class Application
    class Package<MCollective::Application
      description "Install, uninstall, update, purge and perform other actions to packages"

      usage <<-END_OF_USAGE
mco package [OPTIONS] [FILTERS] <ACTION> <PACKAGE>
Usage: mco package <PACKAGE> <install|uninstall|purge|update|status>
       mco package <count|md5>

The ACTION can be one of the following:

    install          - install PACKAGE
    uninstall        - uninstall PACKAGE
    purge            - uninstall PACKAGE and purge related config files
    update           - update PACKAGE
    status           - determine whether PACKAGE is installed and report its version
    count            - determine number of packages installed
    md5              - determine md5 of package list
    yum_clean        - clean the yum cache
    yum_checkupdates - display available updates from yum
    apt_update       - update all available packages
    apt_checkupdates - display available updates from apt
    checkupdates     - display available updates

END_OF_USAGE

      option :yes,
             :arguments   => ["--yes", "-y"],
             :description => "Assume yes on any prompts",
             :type        => :bool

      option :version,
             :arguments   => ["--version VERSION"],
             :description => "Optional VERSION to pass to install",
             :type        => String,
             :required    => false

      def handle_message(action, message, *args)
        messages = {1 => 'Please specify package name and action',
                    2 => "Action has to be one of %s",
                    3 => "Do you really want to operate on packages unfiltered? (y/n): "}
        send(action, messages[message] % args)
      end

      def post_option_parser(configuration)
        valid_global_actions = ['count', 'md5', 'yum_clean', 'yum_checkupdates', 'apt_update', 'checkupdates', 'apt_checkupdates']
        if (ARGV.size < 2) and !valid_global_actions.include?(ARGV[0])
          handle_message(:raise, 1)
        else

          valid_actions = ['install', 'uninstall', 'purge', 'update', 'status'].concat(valid_global_actions)

          if valid_actions.include?(ARGV[0])
            configuration[:action] = ARGV.shift
            unless valid_global_actions.include?(ARGV[0])
              configuration[:package] = ARGV.shift
            end 
          elsif valid_actions.include?(ARGV[1])
            configuration[:package] = ARGV.shift
            configuration[:action] = ARGV.shift
          else
            handle_message(:raise, 2, valid_actions.join(', '))
          end
        end
      end

      def validate_configuration(configuration)
        unless [ 'status', 'count', 'md5'].include?(configuration[:action])
          if Util.empty_filter?(options[:filter]) && !configuration[:yes]
            handle_message(:print, 3)

            STDOUT.flush
            exit(1) unless STDIN.gets.strip.match(/^(?:y|yes)$/i)
          end
        end
      end

      def main
        pkg = rpcclient("package")
        if configuration[:version].nil?
          pkg_result = pkg.send(configuration[:action], :package => configuration[:package])
        else
          pkg_result = pkg.send(configuration[:action], :package => configuration[:package], :version => configuration[:version])
        end

        if !pkg_result.empty?
          sender_width = pkg_result.map{|s| s[:sender]}.map{|s| s.length}.max + 3
          pattern = "%%%ds: %%s" % sender_width

          pkg_result.each do |result|
            if result[:statuscode] == 0
              if pkg.verbose
                if ['count', 'md5'].include?(configuration[:action])
                  puts(pattern % [result[:sender], result[:data][:output]])
                else
                  puts(pattern % [result[:sender], result[:data][:ensure]])
                end
              else
                if configuration[:action] == 'status'
                  if result[:data][:ensure] == 'absent'
                    status = 'absent'
                  else
                    status = "%s-%s.%s" % [result[:data][:name], result[:data][:ensure], result[:data][:arch]]
                  end
                  puts(pattern % [result[:sender], status])
                else
                  if ['count', 'md5'].include?(configuration[:action])
                    status = "%s" % [result[:data][:output]]
                    puts(pattern % [result[:sender], status])
                  end
                end
              end
            else
              puts(pattern % [result[:sender], result[:statusmsg]])
            end
          end

          puts
        end

        printrpcstats :summarize => true, :caption => "%s Package results" % configuration[:action]
        halt(pkg.stats)
      end
    end
  end
end
