# Choria Sysctl Data Plugin

This plugin can retrieve a value from a sysctl variable to be used in agents and discovery.

# Installation

Add the agent and client:

```yaml
mcollective::plugin_classes:
  - mcollective_data_sysctl
```

## Usage

Sample usage to select all machines where ipv4 forwarding is enabled:

```
$ mco find -S "sysctl('net.ipv4.conf.all.forwarding').value=1"
```

## Portability

This plugin works on all systems where sysctl(8) is installed as
`/sbin/sysctl` such as Linux, *BSD, etc.
