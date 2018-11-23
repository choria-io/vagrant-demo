## 0.2.0
Updates the module to be compatible with PDK 1.4.1, adds beaker task helper and relevant functionality.

### Added
- Beaker_task_helper added.
- Rubygems path for Beaker Task Helper.

### Changed
- Module converted using version 1.4.1 of the PDK.

## Release 0.1.5

### Changed
- Nothing, we needed a release.

## Release 0.1.4

### Fixed
- Readme updates.
- Tests work on PE and Bolt.
- Package attribute is now name.

## Release 0.1.3

### Fixed
- Updated readme.
- Fixed locales project name.
- Fixed cli description.

## Release 0.1.2

### Fixed
- Handle providers that return multiple versions (gem)
- Handle providers that don't have latest (windows)
- Handle providers that exit 1 when absent (yum)

## Release 0.1.1
This is the initial release of the package task.

## Features
- Provides the following actions install, status, uninstall and upgrade.
- Upgrade allows specifying a version.
- Provider can optionally be specified, eg gem or apt. 
