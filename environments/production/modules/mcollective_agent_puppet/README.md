# Choria Puppet Agent

This agent manages the *puppet agent* life cycle and has the following features:

  * Supports noop runs or no-noop runs
  * Supports limiting runs to certain tags
  * Support splay, no splay, splaylimits
  * Supports specifying a custom environment
  * Supports specifying a custom master host and port (needs to be explicitly allowed)
  * Support Puppet 3 features like lock messages when disabling
  * Use the new summary plugins to provide convenient summaries where appropriate
  * Use the new validation plugins to provider richer input validation and better errors
  * Data sources for the current puppet agent status and the status of the most recent run

Additionally a number of Playbooks are included:

  * `mcollective_agent_puppet::disable` Disables the Puppet Agent
  * `mcollective_agent_puppet::disable_and_wait` Disables the Puppet Agent and wait for in-progress catalog runs to complete
  * `mcollective_agent_puppet::enable` Enables the Puppet Agent
  * `mcollective_agent_puppet::find_stuck_agents` Finds agents in a stuck state that will not continue without manual intervention

You can use these from other [Choria Playbooks](https://choria.io/docs/playbooks/) or on the CLI

## Actions

This agent provides the following actions, for details about each please run `mco plugin doc agent/puppet`

 * **disable** - Disable the Puppet agent
 * **enable** - Enable the Puppet agent
 * **last_run_summary** - Get the summary of the last Puppet run
 * **resource** - Evaluate Puppet RAL resources
 * **runonce** - Invoke a single Puppet run
 * **status** - Get the current status of the Puppet agent

## Agent Installation

This agent is installed by default as part of the [Choria Orchestrator](https://choria.io).

## Configuring the agent

By default it just works if you run `puppet-agent` from Puppet Inc. There are a few settings you can tweak
using Hiera:

```yaml
mcollective_agent_puppet::config:
  command: "puppet agent"
  splay: true
  splaylimit: 30
  windows_service: puppet
  signal_daemon: true
```

These are the defaults, adjust to taste.

If `command` is not set, it will try to find `puppet` via the PATH environment variable.
On non-Windows systems, `/opt/puppetlabs/bin` will be appended
to PATH if the `command` doesn't include a file path.

> **Warning**: If Puppet is not on the PATH and you are not using the `puppet-agent`
package provided by Puppet, this can result in running a binary placed by any user that
has write access to `/opt`. If that is a concern, ensure `command` is configured.

The agent allows managing of any resource via the Puppet RAL. By default it refuses to
manage a resource also managed by Puppet which could create conflicting state. If you
do wish to allow any resources to be managed set this to true:

```yaml
mcollective_agent_puppet::config:
  resource_allow_managed_resources: true
```

The resource action can manage any resource type Puppet can, by default we blacklist
the all types due to the potential damage this feature can do to your system if not
correctly setup.  You can specify either a whitelist or a blacklist of types this
agent will be able to manage - you cannot specify both a blacklist and a whitelist.

```yaml
mcollective_agent_puppet::config:
  resource_type_whitelist: host,alias
  resource_type_blacklist: exec
```
If you supply the value *none* to *type_whitelist* it will have the effect of denying
all resource management - this is the default.

On Windows, the name of the Puppet service is needed to determine if the
service is running. The service name varies between Puppet open source and
Puppet Enterprise (puppet vs. pe-puppet); the default is puppet, but it can be
explicitly specified:

```yaml
mcollective_agent_puppet::config:
  windows_service: puppet
```

The agent will by default invoke `command` to initiate a
run, passing through any applicable flags to adjust behavior.  On
POSIX-compliant platforms where Puppet is already running in
daemonized mode we support sending the daemonized service a USR1
signal to trigger the daemonized process to perform an immediate
check-in.  This will inhibit customizations to the run (such as noop
or environment), but it is the default.  It's reccomended that you
disable this like so:


```yaml
mcollective_agent_puppet::config:
  signal_daemon: false
```

The agent will not by default accept the server option. If passed then
the agent returns an error. Passing the option can be allowed in the
configuration file like so:

```yaml
mcollective_agent_puppet::config:
  allow_server_override: true
```

## Authorization

By default the Action Policy system is configured to only allow `status` and `last_run_summary`
actions from all users.  These are read only and does not expose secrets.

Follow the Choria documentation to configure your own policies either site wide or per agent.

If you do configure any Policies specific to this module these defaults will be overriden
when done using Hiera.

An example policy can be seen here:

```yaml
mcollective_agent_puppet::policies:
  - action: "allow"
    callers: "choria=manager.mcollective"
    actions: "disable enable"
    facts: "*"
    classes: "*"
```

## Usage
### Running Puppet

Most basic case is just a run:

    $ mco puppet runonce

...against a specific server and port (needs to be explicitly allowed):

    $ mco puppet runonce --server puppet.example.net:1234

...just some tags

    $ mco puppet runonce --tag one --tag two --tag three
    $ mco puppet runonce --tag one,two,three
    $ mco puppet runonce --tags one,two,three

...a noop run

    $ mco puppet runonce --noop

...a actual run when noop is set in the config file

    $ mco puppet runonce --no-noop

...in a specific environment

    $ mco puppet runonce --environment development

...a splay run

    $ mco puppet runonce --splay --splaylimit 120

...or if you have splay on by default and do not want to splay

    $ mco puppet runonce --no-splay

...or if you want to ignore schedules for a single run

    $ mco puppet runonce --ignoreschedules

These can all be combined to your liking

### Requesting agent status

The status of the agent can be obtained:

    $ mco puppet status

     * [ ============================================================> ] 2 / 2

       dev1.example.net: Currently stopped; last completed run 9 minutes 11 seconds ago
       dev2.example.net: Currently stopped; last completed run 9 minutes 33 seconds ago

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


    Finished processing 2 / 2 hosts in 45.01 ms

### Requesting last run status

We can show a graph view of various metrics of the last Puppet run using the
*mco puppet summary* command.

    $ mco puppet summary

    Summary statistics for 15 nodes:

                      Total resources: ▇▁▁▁▁▁▁▁▁▂▁▂▁▁▂▂▁▁▁▂  min: 112.0  avg: 288.9  max: 735.0
                Out Of Sync resources: ▇▂▁▄▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 0.0    avg: 2.5    max: 7.0
                     Failed resources: ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 0.0    avg: 0.0    max: 0.0
                    Changed resources: ▇▂▁▄▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 0.0    avg: 2.5    max: 7.0
                  Corrected resources: ▇▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 0.0    avg: 0.7    max: 2.0
      Config Retrieval time (seconds): ▇▂▁▁▃▁▃▂▁▁▁▁▁▁▁▁▁▁▁▁  min: 2.4    avg: 6.6    max: 15.0
             Total run-time (seconds): ▇▃▂▁▃▂▁▁▂▁▁▁▂▁▁▂▁▁▁▁  min: 6.1    avg: 22.9   max: 73.4
        Time since last run (seconds): ▇▁▂▁▁▂▁▁▁▂▁▁▁▁▁▂▂▂▂▃  min: 86.0   avg: 758.9  max: 1.7k

Here each bar indicates the number of nodes that fall within the region, for
example we can see there are a group of nodes on the right that took longer
to run than the others.

You can find which of those nodes took longer than 50 seconds:

    $ mco find -S "resource().total_time>50"

#### Problems with Displaying the Bars

Not all popular SSH clients display the bars correctly. Please ensure your client has UTF-8
enabled, and uses a suitable font such as [dejavu](http://dejavu-fonts.org/wiki/Main_Page). The
following clients have been confirmed to work:
* [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/) on Windows
* [mintty](http://code.google.com/p/mintty/) on [Cygwin](www.cygwin.com) on Windows

### Enabling and disabling

Puppet 3 supports a message when enabling and disabling

    $ mco rpc puppet disable message="doing some hand hacking"
    $ mco rpc puppet enable

The message will be displayed when requesting agent status if it is disabled,
when no message is supplied a default will be used that will include your
mcollective caller identity and the time

### Running all enabled Puppet nodes

Often after committing a change you want the change to be rolled out to your
infrastructure as soon as possible within the performance constraints of your
infrastructure.

The performance of a Puppet Master generally comes down to the maximum concurrent
Puppet nodes that are applying a catalog it can sustain.

Using the MCollective infrastructure we can determine how many machines are
currently enabled and applying catalogs.

Thus to do a Puppet run of your entire infrastructure keeping the concurrent
Puppet runs as close as possible to 10 nodes at a time you would do:

    $ mco puppet runall 10

Below is the output from a run using a concurrency of 1 to highlight the output
you might expect:

    $ mco puppet runall 1
    2013-01-16 16:14:26: Running all nodes with a concurrency of 1
    2013-01-16 16:14:26: Discovering enabled Puppet nodes to manage
    2013-01-16 16:14:29: Found 2 enabled nodes
    2013-01-16 16:14:32: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:14:37: dev1.example.net schedule status: Started a background Puppet run using the 'puppet agent --onetime --daemonize --color=false' command
    2013-01-16 16:14:38: 1 out of 2 hosts left to run in this iteration
    2013-01-16 16:14:40: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:14:44: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:14:48: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:14:52: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:14:56: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:15:00: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:15:04: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:15:08: Currently 1 node applying the catalog; waiting for less than 1
    2013-01-16 16:15:13: dev2.example.net schedule status: Started a background Puppet run using the 'puppet agent --onetime --daemonize --color=false' command

Here we can see it first finds all machine that are enabled and then periodically
checks if the amount of instances currently applying a catalog is less than the
concurrency and then start as many machines as it can till it once again reaches
the concurrency limit.

Note that you can pass flags like --noop and --no-noop but the splay settings will not work
as the runall command does forced runs which negates splay.

If you wish to repeat this in a loop forever you can pass the --rerun argument giving it
the minimum amount of time a loop over all the nodes must take:

    $ mco puppet runall 1 --rerun 3600

This performs the same run logic as before but when it comes to the end of the run it
will sleep for the difference between 3600 seconds and how long the run took.  If the
run took longer than 3600 seconds it will immediately start a new one.

### Discovering based on agent status

Two data plugins are provided, to see what data is available about the running
agent do:

    $ mco rpc rpcutil get_data source=puppet
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    dev1.example.net
              applying: false
        daemon_present: false
       disable_message:
               enabled: true
               lastrun: 1348745262
         since_lastrun: 7776
                status: stopped

    Finished processing 1 / 1 hosts in 76.34 ms

You can then use any of this data in discovery, to restart apache on machines
with Puppet disable can now be done easily:

    $ mco rpc service restart service=httpd -S "puppet().enabled=false"

You can restart apache on all machine that has File[/srv/www] managed by Puppet:

    $ mco rpc service restart service=httpd -S "resource('file[/srv/wwww]').managed=true"

...or machines that had many changes in the most recent run:

    $ mco rpc service restart service=httpd -S "resource().changed_resources>10"

...or that had failures

    $ mco rpc service restart service=httpd -S "resource().failed_resources>0"

Other available data include config_retrieval_time, config_version, lastrun,
out_of_sync_resources, since_lastrun, total_resources and total_time

### Integration with the Action Policy Authorization plugin

The Action Policy plugin supports querying the above data plugins to express
Authorization rules.

You can therefore use the enabled state of the Puppet Agent to limit access
to other actions.

The use case would be that you want:

 * Only allow services to be stopped during maintenance periods when Puppet is disabled
 * Only allow the site manager to disable Puppet

You can control the service agent with the following policy using the *service.policy*
file:

```yaml
mcollective_agent_puppet::policies:
  - action: "allow"
    callers: "choria=user.mcollective"
    facts: "puppet().enabled=false"
```

And you can then allow the manager user to disable and enable nodes using the
*puppet.policy* file:

```yaml
mcollective_agent_puppet::policies:
  - action: "allow"
    callers: "choria=manager.mcollective"
    actions: "disable enable"
    facts: "*"
    classes: "*"
```

Together this allows you to ensure that you both have a maintenance window and a
period where Puppet will not start services again without your knowledge

Note: The runall action is implemented in terms of the runonce action.  When setting up Actionpolicy rules, be sure to include a runonce action permission.

### Managing individual resources using the RAL

Puppet is built on resource types and providers for those types, an instance of
a resource type looks like:

    host{"db":
      ip  =>  "192.168.1.10"
    }

These are known as the Resource Abstraction Layer or the RAL.

You can use MCollective to manage individual parts of your servers using the
RAL.

To add a host entry to your webservers matching the above resource you can
do the following:

    $ mco puppet resource host db ip=192.168.1.11 -W role::webserver

     * [ ============================================================> ] 11 / 11


     node4.example.net
        Result: ip changed '192.168.1.10' to '192.168.1.11'
    .
    .
    Summary of Changed:

       Changed = 1

    Finished processing 11 / 11 hosts in 118.97 ms

Here we used the RAL to change the hosts entry for the hostname *db* to 192.168.1.11
and the output shows you it changed from a previous value to this entry.

Any hosts where the operation failed will fail in the normal manner

This is a very dangerous feature as people can make real changes to your machines
and potentially cause all kinds of problems.

We support a few restrictions:

  * You can whitelist or blacklist which types can be executed, you want to avoid
    exec types for example
  * You can whitelist or blacklist which resource name can be executed, you want to avoid
    ssh package name for example
  * You can allow or deny the ability to change resources that Puppet is also managing
    as you'd want to avoid creating conflicting state

By default if not specifically configured this feature is not usable as it defaults
to the following configuration:


```yaml
mcollective_agent_puppet::config:
  resource_allow_managed_resources: true
  resource_type_whitelist: none
```

You can allow all types except the exec, service and package types using the
following config line:

```yaml
mcollective_agent_puppet::config:
  resource_type_blacklist: exec,service,package
```

You can say which resource names are allowed or denied. You define whitelist or blacklist
for resource type by adding resource type after `resource_name_whitelist` or
`resource_name_blacklist`, for example:

```yaml
mcollective_agent_puppet::config:
  resource_name_blacklist.package: ssh
```

If you not defined list for resource type, all names are allowed.

You cannot mix and match white and black lists.

So to repeat by default this feature is effectively turned off as there is an empty
whitelist by default - no types are allowed to be managed.  You should think carefully
before enabling this feature and combine it with the Authorization system when you do
