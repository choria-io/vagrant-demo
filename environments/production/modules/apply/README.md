
# apply

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with apply](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Description

The `apply` module contains a task to apply a single arbitrary Puppet resource. This makes it easy to take advantage of existing Puppet content while running tasks.

## Setup

The Puppet agent package must be installed on all target nodes. However, the
Puppet agent service doesn't need to be running. Any external resource types
will need to be present on the target node (either by installing the module or
through pluginsync) before they can be used.

## Usage

To run the `apply::resource` task with `bolt`

```
bolt task run apply::resource --nodes $TARGETNODES type=package title=vim params='{"ensure": "present"}'
```

This task can also be run from a bolt plan:

```
plan install_vim(TargetSpec $nodes) {
  run_task(apply::resource, $nodes, type => 'package', title => 'vim', params => {'ensure' => 'present'})
}
```

## Reference

### Tasks

#### `apply::resource`

##### Parameters

`type String[1]`:
  The type of resource to apply

`title String[1]`:
  The title of the resource to apply

`params Hash[String[1], Data]`:
  A map of parameter names and values to apply

##### Output

On success, the result will contain the following keys:

`type`: The type of the resource that was applied
`title`: The title of the resource that was applied
`changed`: A boolean indicating whether the resource was modified by the task
`changes`: An array of change event, each containing `property`, `previous_value`, `desired_value`, `message` representing a single property changed on the resource. Absent if the resource was not changed.

On failure, the result will contain the previous keys and additionally:

`_error`: An error object describing the failure
`failures`: An array of failure events, each containing `property`, `previous_value`, `desired_value`, `message` representing a single property that failed on the resource.

## Limitations

This is a pre `1.0.0` release and future versions may have breaking changes.

