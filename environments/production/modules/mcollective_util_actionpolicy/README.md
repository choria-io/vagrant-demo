# Choria Action Policy Authorization Plugin

This is a plugin that provides fine grained action level authorization for agents. Any MCollective agent plugins based on SimpleRPC can be restricted with authorization plugins like this one.

# Installation

This agent is installed by default as part of the [Choria Orchestrator](https://choria.io).

# Configuration

There are three settings available for the actionpolicy plugin:

* `allow_unconfigured` -- whether to allow requests to agents that do not have policy files configured. Boolean, with allowed values of `0`, `1`, `y`, `n`; values of `true` or `false` are not allowed. Defaults to `1` in Choria.
* `enable_default` -- whether to use a default policy file. Boolean, with allowed values of `0`, `1`, `y`, `n`; values of `true` or `false` are not allowed. Defaults to `0`.
* `default_name` -- the name of the default policy file, if `enable_default` is set to `1` or `y`.

This plugin is enabled by default in the Choria Orchestrator, you can disable it completely if you wish:

```yaml
mcollective::server_config:
  rpcauthorization: 0
```

Specific configuration options can be set as follows in Hiera, in general you will not need to adjust any of these it's all configured correctly by Choria:

```yaml
mcollective_util_actionpolicy::config:
  allow_unconfigured: false
  enable_default: false
  default_name: default.policy
```

## Default Policy Files

You can optionally have a default policy file that applies in the absence of an agent-specific policy file.

```yaml
mcollective_util_actionpolicy::server_config:
  enable_default: 1
  default_name: default
```
This allows you to create a policy file called default.policy which will be used unless a specific policy file exists. Note that if both
`allow_unconfigured` and `enable_default` are configured, all requests will go through the default policy, as `enable_default` takes precedence
over `allow_unconfigured`.

## Usage

Policies are defined in files like `<configdir>/policies/<agent>.policy`, the Choria Orchestrator allows you to configure all of this using Hiera, please consult the [Choria AAA Documentation](https://choria.io/docs/configuration/aaa/).

Below find references of the configuration files, in Choria all of these are managed by Hiera.

Example: Puppet agent policy file

    # /etc/mcollective/policies/puppet.policy
    policy default deny
    allow   cert=admin          *                       *                *
    allow   cert=acme-devs      *                       customer=acme    acme::devserver
    allow   cert=acme-devs      enable disable status   customer=acme    *

    # /etc/mcollective/policies/service.policy
    policy default deny
    allow   cert=puppet-admins  restart                 (puppet().enabled=false and environment=production) or environment=development

The above policy can be described as:

* Allow the `admin` user to invoke all Puppet actions on all servers.
* Allow the `acme-devs` user to invoke _all_ Puppet actions on machines with the fact _customer=acme_ and the config class _acme::devserver_
* Allow the `acme-devs` user to invoke the _enable, disable and status_ actions on all other machines with fact _customer=acme_
* Allow the `puppet-admins` user to restart services at any time in development but in production only when Puppet has been disabled
* All other commands get denied

Policy File Format
-----

Policy files must have the following format:

* Any lines starting with `#` are comments.
* A single `policy default deny` or `policy default allow` line is permitted; it can go anywhere in the file. This default policy will apply to any commands that don't match a specific rule. If you don't specify a default policy, the value of the `plugin.actionpolicy.allow_unconfigured` setting will be used as the default.
* Any number of _policy lines_ are permitted. These must be **tab delimited** lines with either four or five fields (the final field is optional) in the following order:
    1. `allow` or `deny`
    2. Caller ID --- must be either `*` (always matches) or a space-separated list of caller ID strings (see below)
    3. Actions --- must be either `*` (always matches) or a space-separated list of actions
    4. Facts --- may be either `*` (always matches), a space-separated list of `fact=value` pairs (matches if _every_ listed fact matches), or any valid [compound filter string][compound]
    5. Classes --- may be completely absent (always matches), `*` (always matches), a space-separated list of class names (matches if _every_ listed class is present), or any valid [compound filter string][compound]

### Notes

* Like firewall rules, policy lines are processed **in order** --- ActionPolicy will allow or deny each request using the _first_ rule that matches it. A policy line matches a request if **every** field after the allow/deny field matches.
* Policy lines **must** use hard tabs; editor features that convert tabs to spaces (like Vim's `expandtab`) will result in non-functional policy lines.
* Compound filter strings may match on facts, classes, and data plugins (MCollective 2.2.x or later).  When using data plugins in action policies, you should avoid using slow ones, as this will impact the response times of agents, the client waiting time, etc.

[compound]: http://docs.puppetlabs.com/mcollective/reference/basic/basic_cli_usage.html#complex-compound-or-select-queries


### Caller ID

In the case of a single user the Caller ID strings are always of the form `<kind>=<value>`, but both the kind and the value of the ID will depend on your security plugin. See your security plugin's documentation or code for details. Multiple Caller IDs separated by spaces are supported to allow grouping similar callers together.

You can also define named groups of callers like `sysadmin`, see the Groups section below.

* The recommended SSL security plugin sets caller IDs of `cert=<NAME>`, where `<NAME>` is the filename of the client's public key file (minus the `.pem` extension). So a request validated with the `puppet-admins.pem` public key file would be given a caller ID of `cert=puppet-admins`. This kind of caller ID is cryptographically authenticated.
* The PSK security plugin defaults to caller IDs of `uid=<UID>`, where `<UID>` is the local UID of the client process. [There are several other options available](https://github.com/puppetlabs/marionette-collective/blob/master/plugins/mcollective/security/psk.rb#L79), which can be configured with the `plugin.psk.callertype` setting. **None of PSK's caller IDs are authenticated,** and you should generally not be relying on authorization at all if you are using the PSK security plugin.


### Groups

You can create a file called `<configdir>/policies/groups` with content as here:

    # sample groups file
    sysadmins cert=sa1 cert=sa2

Fields are space separated, group names should match `^([\w\.\-]+)$`

Here we create a `sysadmins` group that has 2 Caller IDs in it, the same rules as above for Caller IDs apply here.  Only Caller IDs can be references not other groups.

This group can then be used where you would normal put a Caller ID:

    allow   sysadmins      *                       customer=acme    acme::devserver

You can list multiple groups in space separated lists.  You cannot mix certnames and group names in the same policy line.

# Hardcoding ActionPolicy Into a Specific Agent

Instead of using the site-wide authorization settings (as described above), you can also hardcode authorization plugins in your agents:

```ruby
module MCollective::Agent
  class Service<RPC::Agent
    authorized_by :action_policy

    # ...
  end
end
```

By hardcoding, you're indicating that the ActionPolicy rules *must* allow this action or it will fail.
