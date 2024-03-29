# Choria Vagrant Demo Environment

This is a demo environment that sets up a working Choria installation using Vagrant and the official modules.

## Features

This setup builds a 3 node cluster, 1 Puppet Server + Choria Broker and 2 other nodes, all running CentOS 7.

 * [Choria Streams](https://choria.io/docs/streams/)
 * [Puppet Tasks](https://choria.io/docs/tasks)
 * [Choria Playbooks](https://choria.io/docs/playbooks)
 * [Puppet Agent](https://forge.puppet.com/choria/mcollective_agent_puppet)
 * [Package Agent](https://forge.puppet.com/choria/mcollective_agent_package)
 * [Service Agent](https://forge.puppet.com/choria/mcollective_agent_service)
 * [File Manager Agent](https://forge.puppet.com/choria/mcollective_agent_filemgr)
 * [Shell Agent](https://forge.puppet.com/choria/mcollective_agent_shell)
 * [Net Test Agent](https://forge.puppet.com/choria/mcollective_agent_nettest)
 * [Process Agent](https://forge.puppet.com/choria/mcollective_agent_process)
 * Standard Choria features like Authentication, Authorization and Auditing
 * Various Choria Scout checks configured

## Requirements

 * Vagrant
 * Enough memory to run 1 x 3GB instance and 2 x 1GB instances
 * The `vbguest` plugin for Vagrant `vagrant plugin install vagrant-vbguest`

## Setup

```
$ git clone https://github.com/choria-io/vagrant-demo.git
$ cd vagrant-demo
$ vagrant plugin install vagrant-vbguest
$ vagrant up
```

## Usage

If the setup step completed correctly you are ready to use some features of Choria:

```
$ vagrant ssh puppet
```

Now you need a unique certificate for you as a user (Authentication):

```
$ choria enroll
Requesting certificate for '/home/vagrant/.puppetlabs/etc/puppet/ssl/certs/vagrant.mcollective.pem'
Waiting up to 240 seconds for it to be signed

Certificate /home/vagrant/.puppetlabs/etc/puppet/ssl/certs/vagrant.mcollective.pem has been stored in /home/vagrant/.puppetlabs/etc/puppet/ssl
```

You can do a quick connectivity test:

```
$ choria ping
puppet.choria                            time=25.25 ms
choria0.choria                           time=25.49 ms
choria1.choria                           time=25.75 ms


---- ping statistics ----
3 replies max: 25.75 min: 25.25 avg: 25.50
```

## Discovery

Choria has Puppet integrated discovery features so you can address your server estate by metadata and not their names. Lets get a report of the roles assigned to the nodes:

```
$ choria facts role
Report for fact: role

        managed                                  found 2 times
        puppetserver                             found 1 times

Finished processing 3 / 3 hosts in 12.51 ms
```

We can see what nodes are `managed` ones:

```
$ choria find -F role=managed
choria0.choria
choria1.choria
```

Lets check when the `managed` nodes last ran Puppet, we use discovery to pick the nodes rather than having to remember hostnames:

```
$ mco puppet status -W role=managed

 * [ ============================================================> ] 2 / 2

   choria1.choria: Currently stopped; last completed run 14 minutes 16 seconds ago
   choria0.choria: Currently stopped; last completed run 14 minutes 40 seconds ago

Summary of Applying:

   false = 2

Summary of Daemon Running:

   stopped = 2

Summary of Enabled:

   enabled = 2

Summary of Idling:

   false = 2

Summary of Status:

   stopped = 2


Finished processing 2 / 2 hosts in 8.44 ms
```

We can also discover based on which Puppet Classes are on the nodes:

```
$ choria find -W choria::broker
puppet.choria
```

Review the section on the [Choria CLI Interaction Model](https://choria.io/docs/concepts/cli/) for more examples and what the output means etc.

## Inspecting a node

We saw a few node names above, lets look at one in particular:

```
$ choria inventory puppet.choria
Inventory for puppet.choria:

   Server Statistics:
                      Version: 2.12.1
                   Start Time: 2018-05-02 10:35:33 +0000
                  Config File: /etc/puppetlabs/mcollective/server.cfg
                  Collectives: mcollective
              Main Collective: mcollective
                   Process ID: 23267
               Total Messages: 15
      Messages Passed Filters: 13
            Messages Filtered: 2
             Expired Messages: 0
                 Replies Sent: 12
         Total Processor Time: 1.08 seconds
                  System Time: 0.32 seconds

   Agents:
      bolt_tasks      choria_util     discovery
      filemgr         nettest         package
      process         puppet          rpcutil
      service         shell

   Data Plugins:
      agent           bolt_task       collective
      fact            fstat           nettest
      package         process         puppet
      resource        service

   Configuration Management Classes:
    choria                         choria::broker                 choria::broker::config
    choria::broker::service        choria::config                 choria::install
    choria::repo                   choria::service                default
    mcollective                    mcollective::config            mcollective::facts
    mcollective::packager          mcollective::plugin_dirs       mcollective::service
    mcollective_agent_bolt_tasks   mcollective_agent_filemgr      mcollective_agent_nettest
    mcollective_agent_package      mcollective_agent_process      mcollective_agent_puppet
    mcollective_agent_service      mcollective_agent_shell        mcollective_choria
    mcollective_data_sysctl        mcollective_util_actionpolicy  profiles::common
    profiles::network_broker       profiles::puppetserver         puppetserver
    puppetserver::config           puppetserver::install          puppetserver::service
    roles::puppetserver            settings

   Facts:
      aio_agent_version => 5.5.1
      architecture => x86_64
      augeas => {"version"=>"1.10.1"}
      augeasversion => 1.10.1
      bios_release_date => 12/01/2006
      bios_vendor => innotek GmbH
      bios_version => VirtualBox
      blockdevice_sda_model => VBOX HARDDISK
      blockdevice_sda_size => 42949672960
      blockdevice_sda_vendor => ATA
      blockdevices => sda
      boardmanufacturer => Oracle Corporation
      boardproductname => VirtualBox
....
```

This is useful when debugging discovery issues or just to obtain information about a specific node. Any of the facts and classes you see can be used in discovery.

### Basic Choria CLI behavior

Choria commands will try to only show you the most appropriate information. What this
means is if you tried to restart a service using Choria it will not show you every
OK, it's only going to show you the cases where it could not complete your request:

```
$ mco service restart sshd
Do you really want to operate on services unfiltered? (y/n): y

 * [ ============================================================> ] 3 / 3

   choria1.choria: Systemd restart for sshd failed!
journalctl log for sshd:
-- Logs begin at Wed 2018-05-02 10:38:44 UTC, end at Wed 2018-05-02 11:12:38 UTC. --
May 02 11:12:38 choria1.choria systemd[1]: Stopping OpenSSH server daemon...
May 02 11:12:38 choria1.choria systemd[1]: Starting OpenSSH server daemon...
May 02 11:12:38 choria1.choria systemd[1]: sshd.service: main process exited, code=exited, status=203/EXEC
May 02 11:12:38 choria1.choria systemd[1]: Failed to start OpenSSH server daemon.
May 02 11:12:38 choria1.choria systemd[1]: Unit sshd.service entered failed state.
May 02 11:12:38 choria1.choria systemd[1]: sshd.service failed.

Summary of Service Status:

   running = 2
   unknown = 1


Finished processing 3 / 3 hosts in 536.84 ms
```

Here you can see it discovered 3 nodes, acted on 3 nodes but 1 of the 3 failed
and it is only showing you the failure.

But when asking the status it assumes you actually want to see the information and so
shows it all with a short overview at the bottom of the most important information to
help you digest the information.

```
$ mco service status sshd

 * [ ============================================================> ] 3 / 3

   choria1.choria: stopped
    puppet.choria: running
   choria0.choria: running

Summary of Service Status:

   running = 2
   stopped = 1


Finished processing 3 / 3 hosts in 23.42 ms
```

The progress bar is usually shown, this shows you the progress as nodes complete the
requested task, you can disable it using the *--np* or *--no-progress* arguments.

This is a key concept to understand in Choria please see [this blog post](http://www.devco.net/archives/2010/08/28/effective_adhoc_commands_in_clusters.php)
for rationale and background.

### Managing Packages

```
$ mco package status puppet-agent

 * [ ============================================================> ] 3 / 3

    puppet.choria: puppet-agent-5.5.1-1.el7.x86_64
   choria0.choria: puppet-agent-5.5.1-1.el7.x86_64
   choria1.choria: puppet-agent-5.5.1-1.el7.x86_64

Summary of Arch:

   x86_64 = 3

Summary of Ensure:

   5.5.1-1.el7 = 3


Finished processing 3 / 3 hosts in 422.07 ms
```

You can also use this to install, update and upgrade packages on the systems see
*mco package --help* for more information.

More information about the Package agent: [Forge](https://forge.puppet.com/choria/mcollective_agent_package)

### Managing Services

The package and service applications behave almost identical so I won't show full output
but you can stop, start, restart and obtain the status of any service.

```
$ mco service status mcollective
.
.
```

See *mco service --help* for more information.

The *package* and *service* managers use the Puppet provider system to do their work so
they support any OS Puppet does.

More information about the Serice agent: [Forge](https://forge.puppet.com/choria/mcollective_agent_service)

### Testing network connectivity

You can easily test if machines are able to reach another host using the nettest agent:

```
$ mco nettest ping puppet.choria
Do you really want to perform network tests unfiltered? (y/n): y

 * [ ============================================================> ] 3 / 3

choria1.choria                           time = 0.271856
choria0.choria                           time = 0.400874
puppet.choria                            time = 0.178753

Summary of RTT:

   Min: 0.179ms  Max: 0.401ms  Average: 0.284ms


Finished processing 3 / 3 hosts in 9.39 ms
```

Similarly you can also test if a TCP connection can be made:

```
$ mco nettest connect puppet.choria 8140
```

This command is best used with a discovery filter, imagine you suspect a machine in
some VLAN is down, you can run ask other machines in that cluster to test it's availability

```
$ mco nettest ping 192.168.2.10 -W cluster=alfa --limit=20%
```

This will ask 20% of the machines in `cluster=alfa` to see if they can connect to the node
in question.

More information about the nettest plugin: [Forge](https://forge.puppet.com/choria/mcollective_agent_nettest)

### Network wide *pgrep*

You can quickly find out what nodes have processes matching some query much like the
Unix pgrep command:

```
$ mco process list ruby

 * [ ============================================================> ] 3 / 3

   choria0.choria

     PID       USER       VSZ            COMMAND
     22428     root       709.242 MB     /opt/puppetlabs/puppet/bin/ruby /opt/puppetlabs/puppet/bin/m

   choria1.choria

     PID       USER       VSZ            COMMAND
     22667     root       703.977 MB     /opt/puppetlabs/puppet/bin/ruby /opt/puppetlabs/puppet/bin/m

   puppet.choria

     PID       USER       VSZ            COMMAND
     23046     puppet     4.049 GB       /usr/bin/java -Xms2g -Xmx2g -Djruby.logger.class=com.puppetl
     23267     root       710.309 MB     /opt/puppetlabs/puppet/bin/ruby /opt/puppetlabs/puppet/bin/m


Summary of The Process List:

           Matched hosts: 3
       Matched Processes: 4
           Resident Size: 321.391 MB
            Virtual Size: 6.123 GB


Finished processing 3 / 3 hosts in 190.16 ms
```

The fields shown are configurable - see [the process agent](https://forge.puppet.com/choria/mcollective_agent_process)

### Puppet Tasks

A few Puppet Tasks are available, use `mco tasks` to explore this feature:

```
$ mco tasks --detail
Known tasks in the production environment

  apt                                  Allows you to perform apt functions
  mcollective_agent_bolt_tasks::ping   A basic echo task to test Choria Tasks functionality
  package                              Manage and inspect the state of packages

Use mco task <TASK> to see task help
```

```
$ mco tasks run package --action status --name puppet-agent -v
Retrieving task metadata for task package from the Puppet Server
Discovering hosts using the mc method for 2 second(s) .... 3
Attempting to download and run task package on 3 nodes

Downloading and verifying 1 file(s) from the Puppet Server to all nodes: ✓  3 / 3
Running task package and waiting up to 60 seconds for it to complete

choria0.choria
   {"status":"up to date","version":"5.5.1-1.el7"}

choria1.choria
   {"status":"up to date","version":"5.5.1-1.el7"}

puppet.choria
   {"status":"up to date","version":"5.5.1-1.el7"}



Summary for task 78b2e6016e235086a9bf021eba588fe8

                       Task Name: package
                          Caller: choria=vagrant.mcollective
                       Completed: 3
                         Running: 0

                      Successful: 3
                          Failed: 0

                Average Run Time: 2.11s
```

The official [Puppet Tasks Documentation](https://choria.io/docs/tasks) should get you familiar with this feature.

### Scripting and raw RPC

So far everything you have seen was purpose specific command line applications built to have
familiar behaviors for their purpose.  Every Choria command though is simply performing
RPC requests to the network which provides these RPC end points.

The last command can be run by interacting with the RPC layer directly:

```
$ choria req process list pattern=ruby --display all
```

Here you can see you're using the *rpc application* to interact with the *process agent* calling
out to its *list action* and supplying the *pattern argument*.

The output will be familiar but now you can see it's more showing you raw data for every node
but still the basic behavior and output format is familiar.

You can interact with any agent and to get a list of available agents run the *mco plugin doc*
command:

```
$ mco plugin doc
Please specify a plugin. Available plugins are:

Agents:
  bolt_tasks                Downloads and runs Puppet Tasks
  choria_util               Choria Utilities
  filemgr                   File Manager
  nettest                   Perform network tests from a mcollective host
  package                   Manage Operating System Packages
  process                   Manages Operating System Processes
  puppet                    Manages the Life Cycle of the Puppet Agent
  rpcutil                   General helpful actions that expose stats and internals to SimpleRPC clients
  service                   Manages Operating System Services
  shell                     Run commands with the local shell
```

And you can ask MCollective to show you available actions and arguments for each:

```
$ choria plugin doc agent/process
```

This will produce auto generated help for the agent showing the available actions etc.

And finally you can easily write a small script to perform the same url test action:

```
#!/opt/puppetlabs/puppet/bin/ruby

require 'mcollective'

include MCollective::RPC

ps = rpcclient("process")

printrpc ps.list(:pattern => "ruby")

printrpcstats
```

If you put this in a script and ran it you should see familiar output.

### Auditing

After you've run a bunch of commands from the list above take a look at the file _/var/log/mcollective-audit.log_
which is an audit log of all actions taken on a machine, there's an example below:

```
$ cat /var/log/puppetlabs/mcollective-audit.log
{"timestamp":"2018-05-02T11:18:10.078825+0000","request_id":"39e34c6aa4865188af215eed992c5488","request_time":1525259890,"caller":"choria=vagrant.mcollective","sender":"puppet.choria","agent":"process","action":"list","data":{"pattern":"ruby","just_zombies":false,"process_results":true}}
{"timestamp":"2018-05-02T11:19:34.906233+0000","request_id":"fbf2288187605ed9b4d01ed632dd3b47","request_time":1525259974,"caller":"choria=vagrant.mcollective","sender":"puppet.choria","agent":"process","action":"list","data":{"pattern":"ruby","process_results":true}}
```

### Choria Scout

Scout is a new feature that will enable monitoring pipelines to be built using Choria, further demo features will be added in future.

A number of Scout Checks are configured:

```
$ ls /etc/choria/machine/
heartbeat  ntp_peer  swap  zombieprocs
```

You can watch the real time event stream these checks produce:

```
$ choria scout watch
```

In another terminal we can force an immediate check of all `swap` checks:

```
$ choria req choria_util machine_transition name=swap transition=FORCE_CHECK
```

The first running `choria scout watch` should see several check transitions and events.


These events are JSON documents in the CloudEvents v1 format published on the network to `choria.machine.watcher.*.state`:

```
$ choria tool sub 'choria.machine.watcher.*.state'
Waiting for messages from topic choria.machine.watcher.*.state on nats://puppet:4222
---- 11:14:13 on topic choria.machine.watcher.nagios.state
{"data":{"protocol":"io.choria.machine.watcher.nagios.v1.state","identity":"choria1.choria","id":"13808047-7298-4a7e-9f6d-5337887ca305","version":"1.0.0","timestamp":1594120453,"type":"nagios","machine":"heartbeat","name":"check","plugin":"","status":"OK","status_code":0,"output":"1594120453","check_time":1594120453,"perfdata":null,"runtime":0.000002961},"id":"b1716b62-db73-448a-834d-6b8cd722d987","source":"io.choria.machine","specversion":"1.0","subject":"choria1.choria","time":"2020-07-07T11:14:13Z","type":"io.choria.machine.watcher.nagios.v1.state"}
```

The nodes will run Prometheus Node Exporter with Scout integration enabled, after a while you can see the data Choria Scout makes available to Prometheus:

```
$ curl -s http://localhost:9100/metrics|grep choria_
# HELP choria_machine_nagios_start_time Time the Choria Machine subsystem started in unix seconds
# TYPE choria_machine_nagios_start_time gauge
choria_machine_nagios_start_time 1.594124867e+09
# HELP choria_machine_nagios_watcher_checks_count Choria Nagios Check Count
# TYPE choria_machine_nagios_watcher_checks_count counter
choria_machine_nagios_watcher_checks_count{name="heartbeat"} 7
choria_machine_nagios_watcher_checks_count{name="ntp_peer"} 3
choria_machine_nagios_watcher_checks_count{name="swap"} 1
choria_machine_nagios_watcher_checks_count{name="zombieprocs"} 1
# HELP choria_machine_nagios_watcher_last_run_seconds Choria Nagios Check Time
# TYPE choria_machine_nagios_watcher_last_run_seconds gauge
choria_machine_nagios_watcher_last_run_seconds{name="heartbeat"} 1.594125181e+09
choria_machine_nagios_watcher_last_run_seconds{name="ntp_peer"} 1.594125139e+09
choria_machine_nagios_watcher_last_run_seconds{name="swap"} 1.594124868e+09
choria_machine_nagios_watcher_last_run_seconds{name="zombieprocs"} 1.594124868e+09
# HELP choria_machine_nagios_watcher_status Choria Nagios Check Status
# TYPE choria_machine_nagios_watcher_status gauge
choria_machine_nagios_watcher_status{name="heartbeat",status="OK"} 0
choria_machine_nagios_watcher_status{name="ntp_peer",status="CRITICAL"} 2
choria_machine_nagios_watcher_status{name="swap",status="UNKNOWN"} 3
choria_machine_nagios_watcher_status{name="zombieprocs",status="UNKNOWN"} 3
```

## Further Reading

There is a lot more to discover about Choria and more to try like [Playbooks](https://choria.io/docs/playbooks/) and [Tasks](https://choria.io/docs/tasks), review the documentation on the official site [choria.io](https://choria.io)
