# Choria Service Agent

The service agent that lets you stop, start, restart and query the statuses of services on your operating system.

This agent can be extended to support different Service managers, by default it
uses Puppet.  See the section later in this document about extendibility.

## Actions

This agent provides the following actions, for details about each please run `mco plugin doc agent/service`

 * **restart** - Restart a service
 * **start** - Start a service
 * **status** - Gets the status of a service
 * **stop** - Stop a service

## Installation

This agent is installed by default as part of the [Choria Orchestrator](https://choria.io).

## Configuration

There is one plugin configuration setting for the service agent.

* provider   - The Util class that implements the start, stop, restart and status behavior. Defaults to 'puppet'

General provider configuration options can then also be set in the config file.

```yaml
mcollective_agent_service::config:
  provider: puppet
  puppet.hasstatus: true
  puppet.hasrestart: true
```

## Authorization

By default the Action Policy system is configured to only allow `status` action for all users.
This is a read only action and does not expose secrets.

Follow the Choria documentation to configure your own policies either site wide or per agent.

If you do configure any Policies specific to this module these defaults will be overriden
when done using Hiera.

An example policy can be seen here:

```yaml
mcollective_agent_service::policies:
  - action: "allow"
    callers: "choria=manager.mcollective"
    actions: "*"
    facts: "*"
    classes: "*"
```

## Usage

```
% mco rpc service status service=httpd -W /dev_server/
Determining the amount of hosts matching filter for 2 seconds .... 4

 * [ ============================================================> ] 4 / 4

Summary of Service Status:

   running = 3
   stopped = 1


Finished processing 4 / 4 hosts in 241.49 ms
```

```
% mco service puppet stop
Do you really want to operate on services unfiltered? (y/n): y

 * [ ============================================================> ] 4 / 4


Summary of Service Status:

   stopped = 4


Finished processing 4 / 4 hosts in 909.01 ms
```

## Data Plugin

The Service agent also supplies a data plugin which uses the Service agent to
check the current status of a service. The data plugin will return 'running'
or 'stopped' and can be used during discovery or any other place where the
MCollective discovery language is used.

```
mco rpc rpcutil ping -S "service('myservice').status=running"
```

## Validator

The Service agent also supplies a validator plugin that will validate if a
given string is a valid service name.

```
validate :service, :service_name
```

## Extending

The default service agent achieves platform portability by using the Puppet
provider system to support service managers on all platforms that Puppet
supports.

If however you are not a Puppet user or simply want to implement some new
method of service management you can do so by providing your own backend
provider for this agent.

A `service` provider that uses the `service` system command has also been
contributed; it can be configured to work with any command that responds to
`mycommand myservice start/stop/restart/status`.

The logic for the Puppet version of this agent is implemented in
`Util::Service::PuppetService`, you can create a custom service implementation
that overrides #start, #stop, #restart, and #status.

To provide compatibility with the service data plugin #status should return
'stopped' if the service is stopped, and 'running' if the service is running.

This agent defaults to `Util::Service::PuppetService` but if you have your own
you can configure it in the config file using:

```yaml
mcollective_agent_service::config:
  provider: puppet
```
