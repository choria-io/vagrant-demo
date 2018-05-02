# Process Agent

An agent that can be used to list running processes on remote machines.

## Actions

This agent provides the following actions, for details about each please run `mco plugin doc agent/process`

 * **list** - List Processes

## Installation

Install the `sys-proctable` RubyGem on all your agent nodes, this Gem uses native extensions and so will need compilers:

**NOTE:** To install this gem you need to have a c++ compiler on your system

```yaml
mcollective_agent_process::gem_dependencies:
  "sys-proctable": "1.2.0"
```

Add the agent and client:

```yaml
mcollective::plugin_classes:
  - mcollective_agent_process
```

### Archlinux

On Archlinux machines the following Hiera data will install the dependencies using native packages and you do not need compilers:

```yaml
mcollective_agent_process::manage_gem_dependencies: false
mcollective_agent_process::package_dependencies:
  ruby-sys-proctable: present
```

## Configuration

The Process client application can be configured to list only a subset of possible process field values. This can be
configured in your client configuration file. Available fields are PID, USER, VSZ, COMMAND, TTY, RSS and STATE.
Unconfigured the output will default to PID, USER, VSZ and COMMAND.

```yaml
mcollective_agent_process::config:
  fields: PID, COMMAND, TTY, STATE
```

## Usage
```
% mco process list ruby

 * [ ============================================================> ] 2 / 2

   node1.your.com

     PID       USER     VSZ            COMMAND
     31187     root     137.465 MB     ruby /usr/sbin/mcollectived --pid=/var/run/mcollectived.pid

   node2.your.com

     PID       USER     VSZ            COMMAND
     5202      root     120.793 MB     /usr/bin/ruby /usr/bin/puppet agent
     17348     root     112.105 MB     ruby /usr/sbin/mcollectived --pid=/var/run/mcollectived.pid


Summary of The Process List:

           Matched hosts: 2
       Matched Processes: 3
           Resident Size: 28.921 MB
            Virtual Size: 370.363 MB


Finished processing 2 / 2 hosts in 134.67 ms
```

```
mco process list ruby --fields=pid,command,state

 * [ ============================================================> ] 2 / 2

   node1.your.com

     PID       COMMAND                                                          STATE
     5202      /usr/bin/ruby /usr/bin/puppet agent                              S
     17348     ruby /usr/sbin/mcollectived --pid=/var/run/mcollectived.pid      R

   node2.your.com

     PID       COMMAND                                                          STATE
     31187     ruby /usr/sbin/mcollectived --pid=/var/run/mcollectived.pid      R


Summary of The Process List:

           Matched hosts: 2
       Matched Processes: 3
           Resident Size: 28.805 MB
            Virtual Size: 369.863 MB


Finished processing 2 / 2 hosts in 96.65 ms
```

## Data Plugin

The Process agent also supplies a data plugin which uses the sys-proctable Gem to check if there exists a process
that matches a given pattern and can be used during discovery or any other place where the MCollective discovery
language is used.

```
mco rpc rpcutil ping -S "process('ruby').exists=true"
```
