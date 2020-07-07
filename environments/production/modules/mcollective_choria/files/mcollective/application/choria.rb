module MCollective
  class Application
    class Choria < Application
      description "Choria Orchestrator Management and Configuration"

      usage <<-USAGE
  mco choria [OPTIONS] <ACTION>

  The ACTION can be one of the following:

     request_cert - requests a certificate from the Puppet CA
     show_config  - shows the active configuration parameters

  The environment is chosen using --environment and the concurrent
  runs may be limited using --batch.

  The batching works a bit different than typical, it will only batch
  based on a sorted list of certificate names, this means the batches
  will always run in predictable order.
  USAGE

      exclude_argument_sections "common", "filter", "rpc"

      option :ca,
             :arguments => ["--ca SERVER"],
             :description => "Address of your Puppet CA",
             :type => String

      option :certname,
             :arguments => ["--certname CERTNAME"],
             :description => "Override the default certificate name",
             :type => String

      def post_option_parser(configuration)
        if ARGV.length >= 1
          configuration[:command] = ARGV.shift
        else
          abort("Please specify a command, valid commands are: %s" % valid_commands.join(", "))
        end

        ENV["MCOLLECTIVE_CERTNAME"] = configuration[:certname] if configuration[:certname]
      end

      # Validates the configuration
      #
      # @return [void]
      def validate_configuration(configuration)
        Util.loadclass("MCollective::Util::Choria")

        unless valid_commands.include?(configuration[:command])
          abort("Unknown command %s, valid commands are: %s" % [configuration[:command], valid_commands.join(", ")])
        end

        if !choria.has_client_public_cert? && !["request_cert", "show_config"].include?(configuration[:command])
          abort("A certificate is needed from the Puppet CA for `%s`, please use the `request_cert` command" % choria.certname)
        end
      end

      def main
        send("%s_command" % configuration[:command])
      rescue Util::Choria::UserError
        STDERR.puts("Encountered a critical error: %s" % Util.colorize(:red, $!.to_s))
      rescue Util::Choria::Abort
        exit(1)
      end

      # Requests a certificate from the CA
      #
      # @return [void]
      def request_cert_command
        disconnect

        unless choria.puppet_security?
          raise(Util::Choria::UserError, "Cannot only request certificates in Puppet security mode")
        end

        if choria.has_client_public_cert?
          raise(Util::Choria::UserError, "Already have a certificate '%s', cannot request a new one" % choria.client_public_cert)
        end

        choria.ca = configuration[:ca] if configuration[:ca]

        certname = choria.client_public_cert

        choria.make_ssl_dirs
        choria.fetch_ca

        if choria.waiting_for_cert?
          puts("Certificate %s has already been requested, attempting to retrieve it" % certname)
        else
          puts("Requesting certificate for '%s'" % certname)
          choria.request_cert
        end

        puts("Waiting up to 240 seconds for it to be signed")
        puts

        puts("Key fingerprint: %s" % choria.csr_fingerprint)
        puts

        24.times do |time|
          print "Attempting to download certificate %s: %d / 24\r" % [certname, time]

          break if choria.attempt_fetch_cert

          sleep 10
        end

        unless choria.has_client_public_cert?
          raise(Util::Choria::UserError, "Could not fetch the certificate after 240 seconds, please ensure it gets signed and rerun this command")
        end

        puts("Certificate %s has been stored in %s" % [certname, choria.ssl_dir])
      end

      def show_config_command # rubocop:disable Metrics/MethodLength
        disconnect

        puts "Active Choria configuration:"
        puts
        puts "The active configuration used in Choria comes from using Puppet AIO defaults, querying SRV"
        puts "records and reading configuration files.  The below information shows the completely resolved"
        puts "configuration that will be used when running MCollective commands"
        puts
        puts "MCollective related:"
        puts
        puts "    MCollective Version: %s" % MCollective::VERSION
        puts "         Choria Version: %s" % Util::Choria::VERSION
        puts "     Client Config File: %s" % Util.config_file_for_user
        puts "     Active Config File: %s" % Config.instance.configfile
        puts "      Plugin Config Dir: %s" % File.join(Config.instance.configdir, "plugin.d")
        puts "      Using SRV Records: %s" % choria.should_use_srv?
        puts "              Federated: %s" % choria.federated?
        puts "             SRV Domain: %s" % choria.srv_domain
        puts "               NATS NGS: %s" % choria.ngs?

        middleware_servers = choria.middleware_servers("puppet", 4222).map {|s, p| "%s:%s" % [s, p]}.join(", ")

        puts "     Middleware Servers: %s" % middleware_servers

        if choria.federated?
          fed_servers = choria.federation_middleware_servers
          if fed_servers
            puts "     Federation Servers: %s" % fed_servers.map {|s, p| "%s:%s" % [s, p]}.join(", ")
          else
            puts "     Federation Servers: %s (fallback to normal client settings)" % middleware_servers
          end
          puts " Federation Collectives: %s" % choria.federation_collectives.join(", ")
        end

        puts

        puppet_server = choria.puppet_server
        puppetca_server = choria.puppetca_server
        puppetdb_server = choria.puppetdb_server

        puts "Puppet related:"
        puts
        puts "       Puppet Server: %s:%s" % [puppet_server[:target], puppet_server[:port]]
        puts "     PuppetCA Server: %s:%s" % [puppetca_server[:target], puppetca_server[:port]]
        puts "     PuppetDB Server: %s:%s" % [puppetdb_server[:target], puppetdb_server[:port]]

        if choria.proxied_discovery?
          proxy_server = choria.discovery_server
          puts "     Discovery Proxy: %s:%s" % [proxy_server[:target], proxy_server[:port]]
        else
          puts "     Discovery Proxy: not using a proxy"
        end

        puts "      Facter Command: %s" % choria.facter_cmd
        puts "       Facter Domain: %s" % choria.facter_domain

        puts

        puts "Security setup:"
        puts

        valid_ssl = choria.check_ssl_setup(false) rescue false

        if valid_ssl
          puts "     Valid SSL Setup: %s" % [Util.colorize(:green, "yes")]
        else
          puts "     Valid SSL Setup: %s try running 'mco choria request_cert'" % [Util.colorize(:red, "no")]
        end

        puts "   Security Provider: %s" % [choria.security_provider]
        puts "            Certname: %s" % [choria.certname]
        puts "       SSL Directory: %s (%s)" % [choria.ssl_dir, File.exist?(choria.ssl_dir) ? Util.colorize(:green, "found") : Util.colorize(:red, "absent")]
        puts "  Client Public Cert: %s (%s)" % [choria.client_public_cert, choria.has_client_public_cert? ? Util.colorize(:green, "found") : Util.colorize(:red, "absent")]
        puts "  Client Private Key: %s (%s)" % [choria.client_private_key, choria.has_client_private_key? ? Util.colorize(:green, "found") : Util.colorize(:red, "absent")]
        puts "             CA Path: %s (%s)" % [choria.ca_path, choria.has_ca? ? Util.colorize(:green, "found") : Util.colorize(:red, "absent")]
        puts "            CSR Path: %s (%s)" % [choria.csr_path, choria.has_csr? ? Util.colorize(:green, "found") : Util.colorize(:red, "absent")]

        if choria.has_client_public_cert?
          cn = choria.valid_certificate?(File.read(choria.client_public_cert), choria.certname, false)

          puts "      Public Cert CN: %s (%s)" % [cn, cn == choria.certname ? Util.colorize(:green, "match") : Util.colorize(:red, "does not match certname")]
        end

        if choria.credential_file?
          puts "    NATS Credentials: %s (%s)" % [
            choria.credential_file,
            File.exist?(choria.credential_file) ? Util.colorize(:green, "exit") : Util.colorize(:red, "does not exist")
          ]
          puts "         'nkeys' gem: %s" % choria.nkeys?
        end

        puts

        puts "Active Choria configuration settings as found in configuration files:"
        puts

        choria_settings = Config.instance.pluginconf.select {|k, _| k.start_with?("choria")}
        padding = choria_settings.empty? ? 2 : choria_settings.keys.map(&:length).max + 2

        if choria_settings.empty?
          puts "  No custom Choria settings found in your configuration files"
        else
          choria_settings.each do |k, v|
            puts "%#{padding}s: %s" % [k, v]
          end
        end

        puts
      end

      # Creates and cache a Choria helper class
      #
      # @return [Util::Choria]
      def choria
        @_choria ||= Util::Choria.new(false)
      end

      # List of valid commands this application respond to
      #
      # @return [Array<String>] like `plan` and `run`
      def valid_commands
        methods.grep(/_command$/).map {|c| c.to_s.gsub("_command", "")}
      end

      # Asks the user to confirm something on the CLI
      #
      # @note exits the application on no
      # @param msg [String] the message to ask
      # @return [void]
      def confirm(msg)
        print("%s (y/n) " % msg)

        STDOUT.flush

        exit(1) unless STDIN.gets.strip.match?(/^(?:y|yes)$/i)
      end
    end
  end
end
