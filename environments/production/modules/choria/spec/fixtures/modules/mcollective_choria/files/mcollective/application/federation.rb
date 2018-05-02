module MCollective
  class Application
    class Federation < Application
      description "Choria Federation Brokers"

      usage <<-USAGE
mco federation [OPTIONS] <ACTION>

The ACTION can be one of the following:

   observe       - view the published Federation Broker statistics
   trace         - trace the path to a client
   broker        - start a Federation Broker instance

USAGE

      exclude_argument_sections "common", "filter", "rpc"

      option :cluster,
             :arguments => ["--cluster CLUSTER"],
             :description => "Cluster name to observe or serve",
             :type => String

      option :instance,
             :arguments => ["--instance INSTANCE"],
             :description => "Instance name to observe or serve",
             :type => String

      option :stats_port,
             :arguments => ["--stats-port PORT", "--stats"],
             :description => "HTTP port to listen to for stats",
             :type => Integer

      # Publish a specially crafted 'ping' with seen-by headers
      # embedded, this signals to the entire collective to record
      # their route
      def trace_node(node)
        options[:filter] = Util.empty_filter

        request = Message.new("ping", nil,
                              :agent => "discovery",
                              :filter => options[:filter],
                              :collective => options[:collective],
                              :type => :request,
                              :headers => {"seen-by" => []},
                              :options => options)

        request.discovered_hosts = [node]

        client = Client.new(options)
        found_time = 0
        route = []

        stats = client.req(request) do |reply, message|
          abort("Tracing requests requires MCollective 2.10.3 or newer") unless message

          found_time = Time.now.to_f

          unless reply[:senderid] == node
            abort("Received a response from %s while expecting a response from %s" % [reply[:senderid], node])
          end

          route = message.headers["seen-by"]
        end

        raise("Did not receive any responses to trace request") if stats[:responses] == 0

        {:route => route, :stats => stats, :response_time => (found_time - stats[:starttime]), :request => request.requestid}
      end

      def route_to(route, destination)
        route.take_while {|hop| hop[1] != destination}
      end

      def route_back(route, destination)
        route.reverse.take_while {|hop| hop.size == 2 || hop[1] != destination}.reverse
      end

      def destination_hop(route)
        route[route_to(route, destination).size]
      end

      def extract_federation_brokers(route, destination)
        abort("Unexpected route size %d found" % route.size) unless route.size == 5

        [route_to(route, destination).last[1], route_back(route, destination).first[1]]
      end

      def draw_cluster(left, right, direction, indent)
        if left.last == right.first && direction == :out
          "%s└── %s" % [" " * indent, left.last]
        elsif left.last == right.first
          "%s┌── %s" % [" " * indent, left.last]
        elsif direction == :out
          [
            "%s└─┐ %s" % [" " * indent, left.last],
            "%s  └ %s" % [" " * indent, right.first]
          ].join("\n")
        else
          [
            "%s  ┌ %s" % [" " * indent, left.last],
            "%s┌─┘ %s" % [" " * indent, right.first]
          ].join("\n")
        end
      end

      # @todo this is aweful brute force rubbish while I dont know what I want, make some algo
      def display_unfederated_route(route)
        c_out, node, c_in = route

        if c_out[1] == node[0] && node[2] == c_out[1] && node[0] == c_out[1]
          puts "  Shared Middleware"
          puts
          puts "    %s" % Util.colorize(:cyan, c_out[0])
          puts draw_cluster(c_out, node, :out, 7)
          puts "           └── %s" % Util.colorize(:yellow, node[1])

        elsif c_out[1] == c_in[0] && node[0] == node[2]
          puts "  NATS Cluster with Symetrical Path"
          puts
          puts "    %s" % Util.colorize(:cyan, c_out[0])
          puts draw_cluster(c_out, node, :out, 7)
          puts "           └── %s" % Util.colorize(:yellow, node[1])

        else
          puts "  NATS Cluster with Asymmetrical Path"
          puts
          puts "  %s" % Util.colorize(:cyan, c_out[0])
          puts draw_cluster(c_out, node, :out, 5)
          puts "         ├── %s" % Util.colorize(:yellow, node[1])
          puts draw_cluster(node, c_in, :in, 5)
          puts "  %s" % Util.colorize(:cyan, c_in[1])
        end
        puts
        puts "[%s] Client [%s] Server [%s] Middleware" % [
          Util.colorize(:cyan, "█"), Util.colorize(:yellow, "█"), "█"
        ]
        puts
      end

      # @todo this is aweful brute force rubbish while I dont know what I want, make some algo
      def display_federated_route(route)
        c_out, fb1, node, fb2, c_in = route

        puts "  %s" % Util.colorize(:bold, "Request:")
        puts "    %s" % Util.colorize(:cyan, c_out[0])
        puts draw_cluster(c_out, fb1, :out, 7)
        puts "            └─ %s" % Util.colorize(:green, fb1[1])
        puts draw_cluster(fb1, node, :out, 15)
        puts "                    └── %s" % Util.colorize(:yellow, node[1])
        puts
        puts "  %s" % Util.colorize(:bold, "Reply:")
        puts "                    ┌── %s" % Util.colorize(:yellow, node[1])
        puts draw_cluster(node, fb2, :int, 15)
        puts "            ┌─ %s" % Util.colorize(:green, fb2[1])
        puts draw_cluster(fb2, c_in, :in, 7)
        puts "    %s" % Util.colorize(:cyan, c_in[1])
        puts
        puts "[%s] Client [%s] Federation Broker [%s] Server [%s] Middleware" % [
          Util.colorize(:cyan, "█"), Util.colorize(:green, "█"), Util.colorize(:yellow, "█"), "█"
        ]
        puts
      end

      def trace_command
        result = trace_node(configuration[:host])

        abort("No routes were reported, are your nodes running a supported version?") if result[:route].empty?

        puts "Received response from %s in %.2fms for message %s" % [configuration[:host], result[:response_time] * 1000, result[:request]]
        puts

        route = result[:route]
        puts "Reported Route:"
        puts
        if route.size == 5
          display_federated_route(route)
        elsif route.size == 3
          display_unfederated_route(route)
        end

        puts

        puts "Federation Brokers Instances:"
        puts
        if choria.federated?
          extract_federation_brokers(result[:route], configuration[:host]).sort.uniq.each do |broker|
            puts "  %s" % broker
          end
        else
          puts "  Unfederated"
        end
        puts

        puts "Known Federation Broker Clusters:"
        puts
        if choria.federated?
          puts "  %s" % choria.federation_collectives.join(", ")
        else
          puts "  Unfederated"
        end
      end

      def broker_command
        configuration[:cluster] = Config.instance.pluginconf["choria.federation.cluster"] unless configuration[:cluster]
        configuration[:instance] = Config.instance.pluginconf["choria.federation.instance"] unless configuration[:instance]

        abort("A cluster name is required, use --cluster or plugin.choria.federation.cluster") unless configuration[:cluster]

        Log.warn("Using a UUID based instance name, use --instance of plugin.choria.federation.instance") unless configuration[:instance]

        # app framework would set this to just 'federation' which is not helping
        $0 = "choria %s_%s federation broker [%s]" % [configuration[:cluster], configuration[:instance], Config.instance.configfile]

        broker = choria.federation_broker(
          configuration[:cluster],
          configuration[:instance],
          configuration[:stats_port]
        )

        broker.start

        sleep 10 while broker.ok?

        Log.error("Some broker threads died, exiting: %s" % broker.thread_status.pretty_inspect)

        exit(1)
      end

      def observe_command
        abort("Cannot observe using a client that is not configured for Federation, please set choria.federation.collectives or CHORIA_FED_COLLECTIVE") unless choria.federated?

        puts "Waiting for cluster stats to be published ...."

        choria.federation_broker(configuration[:cluster]).observe_stats do |stats|
          next if stats.empty?

          print "\e[H\e[2J"

          puts "Federation Broker: %s" % Util.colorize(:bold, configuration[:cluster])
          puts

          ["federation", "collective"].each do |type|
            type_stats = {"sent" => 0, "received" => 0, "instances" => {}}

            stats.keys.sort.each do |instance|
              type_stats["sent"] += stats[instance][type]["sent"]
              type_stats["received"] += stats[instance][type]["received"]
              type_stats["instances"][instance] ||= {}
              type_stats["instances"][instance][type] = {
                "sent" => stats[instance][type]["sent"],
                "received" => stats[instance][type]["received"],
                "last" => stats[instance][type]["lasst_message"]
              }
            end

            puts "%s" % Util.colorize(:bold, type.capitalize)
            puts "  Totals:"
            puts "    Received: %d  Sent: %d" % [type_stats["received"], type_stats["sent"]]
            puts
            puts "  Instances:"

            padding = type_stats["instances"].keys.map(&:length).max + 4

            type_stats["instances"].keys.sort.each do |instance|
              puts "%#{padding}s: Received: %d (%.1f%%) Sent: %d (%.1f%%)" % [
                instance,
                type_stats["instances"][instance][type]["received"],
                type_stats["instances"][instance][type]["received"] / type_stats["received"].to_f * 100,
                type_stats["instances"][instance][type]["sent"],
                type_stats["instances"][instance][type]["sent"] / type_stats["sent"].to_f * 100
              ]
            end

            puts
          end

          puts Util.colorize(:bold, "Instances:")

          stats.keys.sort.each do |instance|
            puts "  %s: version %s started %s" % [
              instance,
              stats[instance]["version"],
              Time.at(stats[instance]["start_time"]).strftime("%F %T")
            ]
          end

          puts
          puts "Updated: %s" % Time.now.strftime("%F %T")
        end
      end

      # Creates and cache a Choria helper class
      #
      # @return [Util::Choria]
      def choria
        @_choria ||= Util::Choria.new
      end

      def post_option_parser(configuration)
        if ARGV.length >= 1
          configuration[:command] = ARGV.shift
        else
          abort("Please specify a command, valid commands are: %s" % valid_commands.join(", "))
        end

        if configuration[:command] == "trace"
          if ARGV.length >= 1
            configuration[:host] = ARGV.shift
          else
            abort("Please specify a host to trace, example: mco federation trace node1.prod.example.net")
          end
        end
      end

      def validate_configuration(configuration)
        Util.loadclass("MCollective::Util::Choria")

        unless valid_commands.include?(configuration[:command])
          abort("Unknown command %s, valid commands are: %s" % [configuration[:command], valid_commands.join(", ")])
        end

        if !choria.has_client_public_cert? && !["request_cert", "show_config"].include?(configuration[:command])
          abort("A certificate is needed from the Puppet CA for `%s`, please use the `request_cert` command" % choria.certname)
        end

        if configuration[:command] == "observe"
          abort("When observing a Federation Broker the --cluster option is required") unless configuration[:cluster]
        end
      end

      def main
        send("%s_command" % configuration[:command])
      rescue Interrupt
        exit
      end

      # List of valid commands this application respond to
      #
      # @return [Array<String>] like `plan` and `run`
      def valid_commands
        methods.grep(/_command$/).map {|c| c.to_s.gsub("_command", "")}
      end
    end
  end
end
