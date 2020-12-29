# mcollective_agent_bolt_tasks

#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
1. [Configuration](#data-reference)

## Overview

Agent to support executing Bolt Tasks using Choria

See [choria.io](https://choria.io/docs/tasks/) for full details

## Module Description

## Usage

A deployment guide can be found at the [Choria Website](https://choria.io/docs/tasks/)

## Data Reference

  * `mcollective_choria::gem_dependencies` - Deep Merged Hash of gem name and version this module depends on
  * `mcollective_choria::manage_gem_dependencies` - disable managing of gem dependencies
  * `mcollective_choria::package_dependencies` - Deep Merged Hash of package name and version this module depends on
  * `mcollective_choria::manage_package_dependencies` - disable managing of packages dependencies
  * `mcollective_choria::class_dependencies` - Array of classes to include when installing this module
  * `mcollective_choria::package_dependencies` - disable managing of class dependencies
  * `mcollective_choria::config` - Deep Merged Hash of common config items for this module
  * `mcollective_choria::server_config` - Deep Merged Hash of config items specific to managed nodes
  * `mcollective_choria::client_config` - Deep Merged Hash of config items specific to client nodes
  * `mcollective_choria::client` - installs client files when true - defaults to `$mcollective::client`
  * `mcollective_choria::server` - installs server files when true - defaults to `$mcollective::server`
  * `mcollective_choria::ensure` - `present` or `absent`
