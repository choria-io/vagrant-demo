
# package

#### Table of Contents

1. [Description](#description)
2. [Requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Getting help - Some Helpful commands](#getting-help)

## Description

This module provides the package task. This task allows you to install, uninstall, update, and check the status of packages.

## Requirements
This module is compatible with Puppet Enterprise and Puppet Bolt.

* To run tasks with Puppet Enterprise, PE 2018.1 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must be Puppet agents.

* To run tasks with Puppet Bolt, Bolt 1.0 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must have SSH or WinRM services enabled.

## Usage

To run a package task, use the task command, specifying the action and the name of the package.

* With PE on the command line, run `puppet task run package action=<ACTION> name=<PACKAGE_NAME>`.
* With Bolt on the command line, run `bolt task run package action=<ACTION> name=<PACKAGE_NAME>`.

For example, to check whether the vim package is present or absent, run:

* With PE, run `puppet task run package action=status name=vim --nodes neptune`.
* With Bolt, run `bolt task run package action=status name=vim --nodes neptune --modulepath ~/modules`.

You can also run tasks in the PE console. See PE task documentation for complete information.

## Reference

To view the available actions and parameters, on the command line, run `puppet task show package` or see the package module page on the [Forge](https://forge.puppet.com/puppetlabs/package/tasks).

For a complete list of optional package providers that are supported, see the [Puppet Types](https://docs.puppet.com/puppet/latest/types/package.html) documentation.

## Limitations

To run acceptance tests against Windows machines, ensure that the `BEAKER_password` environment variable has been set to the password of the Administrator user of the target machine.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-package/blob/master/metadata.json)

## Getting Help

To display help for the package task, run `puppet task show package`

To show help for the task CLI, run `puppet task run --help` or `bolt task run --help`

