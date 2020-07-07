----------
At this point, the module was converted to the PDK.
----------

## Unsupported Release 0.5.0
### Summary
This release increases the upper bounds of several dependencies and adds support for two new OS.

### Changed
- Moved upper bound of compatible puppet from >= 6.0.0 to >= 7.0.0.
- Moved upper bound of compatible puppetlabs-stdlib from >= 5.0.0 to >= 6.0.0.
- Moved upper bound of compatible puppetlabs-concat from >= 5.0.0 to >= 6.0.0.
- Support added for Ubuntu 16.04 and 18.04.

## Unsupported Release 0.4.0
### Summary
This release drops outdated stdlib validate functions.

### Changed
- Moved lower bound of compatible puppet from >= 4.0.0 to >= 4.7.0

### Fixed
- Fixed warnings raised by old `validate_*` methods

## Unsupported Release 0.3.0
### Summary

Small release that updates module dependencies.

#### Changed
- puppetlabs-concat and puppetlabs-stdlib dependencies

#### Removed
- Puppet Enterprise requirement. This dependency is no longer used for modules.

## Unsupported Release 0.2.0
### Summary

A small release including a couple of added features and metadata/readme fixes.

#### Added
* Hash to data types for allow and deny rules
* support for extensions matching - updates the validation to ensure that a valid allow/deny entry has been supplied

#### Fixed
* the concat version dependancy
* readme updates - removed unused links also

## Unsupported Release 0.1.0
### Summary

This is the initial release of the module.

#### Features
* Manages the `auth.conf` file using authorization rules written as Puppet resources.
