
# package

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
     * [Requirements](#requirements)
4. [Usage](#usage)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

This module provides the package task.

## Description

This task allows you to install, uninstall, update, and check the status of packages.

## Setup

### Requirements

This module is compatible with Puppet Enterprise and Puppet Bolt.

* To run tasks with Puppet Enterprise, PE 2018.1 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must be Puppet agents.

* To run tasks with Puppet Bolt, Bolt 1.0 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must have SSH or WinRM services enabled.

## Usage

To view the available actions and parameters, on the command line, run `puppet task show package` or see the package module page on the [Forge](https://forge.puppet.com/puppetlabs/package/tasks).
For a complete list of optional package providers that are supported, see the [Puppet Types](https://docs.puppet.com/puppet/latest/types/package.html) documentation.

To run a package task, use the task command, specifying the action and the name of the package.
To show help for the task CLI, run `puppet task run --help` or `bolt task run --help`

* With PE on the command line, run `puppet task run package action=<ACTION> name=<PACKAGE_NAME>`.
* With Bolt on the command line, run `bolt task run package action=<ACTION> name=<PACKAGE_NAME>`.

For example, to check whether the vim package is present or absent, run:

* With PE, run `puppet task run package action=status name=vim --nodes neptune`.
* With Bolt, run `bolt task run package action=status name=vim --nodes neptune --modulepath ~/modules`.

You can also run tasks in the PE console. See PE task documentation for complete information.

## Reference

For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-package/blob/master/REFERENCE.md).

## Limitations

To run acceptance tests against Windows machines, ensure that the `BEAKER_password` environment variable has been set to the password of the Administrator user of the target machine.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-package/blob/master/metadata.json)

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. To contribute to Puppet projects, see our [module contribution guide.](https://github.com/puppetlabs/puppetlabs-package/blob/master/CONTRIBUTING.md)

