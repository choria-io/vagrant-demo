# Choria File Manager Agent

This agent let you touch files, delete files or retrieve a bunch of stats about a file.

## Actions

This agent provides the following actions, for details about each please run `mco plugin doc agent/filemgr`

 * **remove** - Removes a file
 * **status** - Basic information about a file
 * **touch** - Creates an empty file or touch it's timestamp

## Installation

This agent is installed by default as part of the [Choria Orchestrator](https://choria.io).

## Configuration

Actions `status`, `remove` and `touch` have a default file when no file path is given, it defaults to `/var/run/mcollective.plugin.filemgr.touch`.

To cofigure this create the following Hiera data:

```yaml
mcollective_agent_filemgr::config:
  touch_file: "/tmp/touchfile"
```

## Usage

To get the status of a file:

```
% mco rpc filemgr status file=/etc/puppet/puppet.conf
Determining the amount of hosts matching filter for 2 seconds .... 1

 * [ ============================================================> ] 1 / 1


dev1.example.com:
   Modification time: 1289650072
         Change time: Wed Nov 17 00:29:17 +0000 2010
         Change time: 1289953757
                Name: /etc/puppet/puppet.conf
               Owner: 0
         Access time: 1291150379
               Group: 0
                Size: 385
         Access time: Tue Nov 30 20:52:59 +0000 2010
             Present: 1
                Type: file
                Mode: 100644
   Modification time: Sat Nov 13 12:07:52 +0000 2010
                 MD5: 91b8793f2a467aa5d28f6371d3622090
              Status: present


Finished processing 1 / 1 hosts in 71.65 ms
```

You can similarly `touch` and `remove` a file using those named actions.
