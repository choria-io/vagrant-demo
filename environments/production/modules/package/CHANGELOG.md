# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v0.6.0](https://github.com/puppetlabs/puppetlabs-package/tree/v0.6.0) (2019-06-12)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-package/compare/v0.5.0...v0.6.0)

### Changed

- pdksync - \(MODULES-8444\) - Raise lower Puppet bound [\#123](https://github.com/puppetlabs/puppetlabs-package/pull/123) ([david22swan](https://github.com/david22swan))

### Added

- \(FM-8156\) Add Windows Server 2019 support [\#129](https://github.com/puppetlabs/puppetlabs-package/pull/129) ([eimlav](https://github.com/eimlav))
- \(FM-8044\) Add Redhat8 support [\#128](https://github.com/puppetlabs/puppetlabs-package/pull/128) ([sheenaajay](https://github.com/sheenaajay))
- \(Bolt-1104\) - Add linux package task uninstall [\#126](https://github.com/puppetlabs/puppetlabs-package/pull/126) ([m0dular](https://github.com/m0dular))

### Fixed

- FM-7946 stringify package [\#127](https://github.com/puppetlabs/puppetlabs-package/pull/127) ([lionce](https://github.com/lionce))

## [v0.5.0](https://github.com/puppetlabs/puppetlabs-package/tree/v0.5.0) (2019-04-10)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-package/compare/0.4.1...v0.5.0)

### Added

- \(SEN-795\) Move extension metadata to init.json [\#119](https://github.com/puppetlabs/puppetlabs-package/pull/119) ([conormurraypuppet](https://github.com/conormurraypuppet))
- \(SEN-795\) Add discovery extension metadata [\#118](https://github.com/puppetlabs/puppetlabs-package/pull/118) ([conormurraypuppet](https://github.com/conormurraypuppet))
- \(BOLT-1104\) Unify task implementation output [\#117](https://github.com/puppetlabs/puppetlabs-package/pull/117) ([donoghuc](https://github.com/donoghuc))

### Fixed

- \(MODULES-8717\) Fix for boltspec run dependancy issue [\#113](https://github.com/puppetlabs/puppetlabs-package/pull/113) ([HelenCampbell](https://github.com/HelenCampbell))

## [0.4.1](https://github.com/puppetlabs/puppetlabs-package/tree/0.4.1) (2019-01-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-package/compare/0.4.0...0.4.1)

### Fixed

- \(MODULES-8425\) Move to GEM\_BOLT pattern [\#100](https://github.com/puppetlabs/puppetlabs-package/pull/100) ([donoghuc](https://github.com/donoghuc))

## [0.4.0](https://github.com/puppetlabs/puppetlabs-package/tree/0.4.0) (2019-01-08)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-package/compare/0.3.0...0.4.0)

### Added

- \(MODULES-8390\) Enable implementations on the init task and hide others [\#96](https://github.com/puppetlabs/puppetlabs-package/pull/96) ([MikaelSmith](https://github.com/MikaelSmith))

### Fixed

- pdksync - \(FM-7655\) Fix rubygems-update for ruby \< 2.3 [\#97](https://github.com/puppetlabs/puppetlabs-package/pull/97) ([tphoney](https://github.com/tphoney))
- \(MODULES-8045\) Fix apt-get upgrading everything when no version passed and apt is package manager. [\#92](https://github.com/puppetlabs/puppetlabs-package/pull/92) ([eoinmcq](https://github.com/eoinmcq))

## [0.3.0](https://github.com/puppetlabs/puppetlabs-package/tree/0.3.0) (2018-09-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-package/compare/0.2.0...0.3.0)

### Added

- pdksync - \(FM-7392\) - Puppet 6 Testing Changes [\#88](https://github.com/puppetlabs/puppetlabs-package/pull/88) ([pmcmaw](https://github.com/pmcmaw))
- \(DI-3260\) Adding agentless windows task \(for choco\) [\#81](https://github.com/puppetlabs/puppetlabs-package/pull/81) ([HairyMike](https://github.com/HairyMike))
- \(DI-2373\) Adding agentless linux task [\#77](https://github.com/puppetlabs/puppetlabs-package/pull/77) ([tphoney](https://github.com/tphoney))
- \(FM-7263\) - Addition of support for ubuntu 18.04 [\#70](https://github.com/puppetlabs/puppetlabs-package/pull/70) ([david22swan](https://github.com/david22swan))
- \[FM-7058\] Addition of support for Debian 9 to package [\#69](https://github.com/puppetlabs/puppetlabs-package/pull/69) ([david22swan](https://github.com/david22swan))

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


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
