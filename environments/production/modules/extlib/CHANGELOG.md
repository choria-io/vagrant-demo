# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.2.0](https://github.com/voxpupuli/puppet-extlib/tree/v4.2.0) (2020-01-25)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v4.1.0...v4.2.0)

**Implemented enhancements:**

- This PR adds a new fact puppet\_config [\#143](https://github.com/voxpupuli/puppet-extlib/pull/143) ([b4ldr](https://github.com/b4ldr))

**Merged pull requests:**

- Remove duplicate CONTRIBUTING.md file [\#141](https://github.com/voxpupuli/puppet-extlib/pull/141) ([dhoppe](https://github.com/dhoppe))
- drop Ubuntu 14.04 support [\#140](https://github.com/voxpupuli/puppet-extlib/pull/140) ([bastelfreak](https://github.com/bastelfreak))

## [v4.1.0](https://github.com/voxpupuli/puppet-extlib/tree/v4.1.0) (2019-11-07)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Add experimental `extlib::read_url` function [\#137](https://github.com/voxpupuli/puppet-extlib/pull/137) ([alexjfisher](https://github.com/alexjfisher))

## [v4.0.0](https://github.com/voxpupuli/puppet-extlib/tree/v4.0.0) (2019-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v3.1.0...v4.0.0)

**Breaking changes:**

-  modulesync 2.7.0 &  Drop puppet4; require at least Puppet 5.5.8 [\#132](https://github.com/voxpupuli/puppet-extlib/pull/132) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Allow `puppetlabs/stdlib` 6.x [\#134](https://github.com/voxpupuli/puppet-extlib/pull/134) ([alexjfisher](https://github.com/alexjfisher))
- Add new file based functions [\#129](https://github.com/voxpupuli/puppet-extlib/pull/129) ([logicminds](https://github.com/logicminds))

**Merged pull requests:**

- Improve `extlib::path_join` docs formatting [\#133](https://github.com/voxpupuli/puppet-extlib/pull/133) ([alexjfisher](https://github.com/alexjfisher))

## [v3.1.0](https://github.com/voxpupuli/puppet-extlib/tree/v3.1.0) (2018-12-19)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Mark Debian 9 and Ubuntu 18.04 as supported [\#126](https://github.com/voxpupuli/puppet-extlib/pull/126) ([ekohl](https://github.com/ekohl))
- allow puppet 6.x and modulesync 2.1.0 [\#124](https://github.com/voxpupuli/puppet-extlib/pull/124) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-extlib/tree/v3.0.0) (2018-09-28)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v2.3.1...v3.0.0)

In this release, all functions have been moved to the `extlib::` namespace and converted to the 4.X function API.  Non name-spaced versions are still available, but deprecated and will be removed in a future major release.

During the conversion work, a couple of functions have minor but technically breaking changes.  These are documented below.

**Breaking changes:**

- Convert `random_password` to API 4 function [\#112](https://github.com/voxpupuli/puppet-extlib/pull/112) ([alexjfisher](https://github.com/alexjfisher))
- Convert `ip_to_cron` to API 4 function [\#111](https://github.com/voxpupuli/puppet-extlib/pull/111) ([alexjfisher](https://github.com/alexjfisher))

**Closed issues:**

- cache\_data\(\) stores data locally on puppetserver [\#80](https://github.com/voxpupuli/puppet-extlib/issues/80)
- Document ip\_to\_cron in README [\#58](https://github.com/voxpupuli/puppet-extlib/issues/58)

**Merged pull requests:**

- Clean up documentation [\#121](https://github.com/voxpupuli/puppet-extlib/pull/121) ([alexjfisher](https://github.com/alexjfisher))
- Namespace functions [\#120](https://github.com/voxpupuli/puppet-extlib/pull/120) ([alexjfisher](https://github.com/alexjfisher))
- Convert `dump_args` to API 4.x function [\#118](https://github.com/voxpupuli/puppet-extlib/pull/118) ([alexjfisher](https://github.com/alexjfisher))
- Use Optional\[String\] in default\_content\(\) [\#117](https://github.com/voxpupuli/puppet-extlib/pull/117) ([ekohl](https://github.com/ekohl))
- Convert `resources_deep_merge` to API 4.x function [\#116](https://github.com/voxpupuli/puppet-extlib/pull/116) ([alexjfisher](https://github.com/alexjfisher))
- Rewrite cache\_data to 4.x API [\#114](https://github.com/voxpupuli/puppet-extlib/pull/114) ([ekohl](https://github.com/ekohl))
- Convert `echo` function to 4.x API [\#109](https://github.com/voxpupuli/puppet-extlib/pull/109) ([alexjfisher](https://github.com/alexjfisher))
- Fix default\_content puppet-strings tags [\#108](https://github.com/voxpupuli/puppet-extlib/pull/108) ([alexjfisher](https://github.com/alexjfisher))

## [v2.3.1](https://github.com/voxpupuli/puppet-extlib/tree/v2.3.1) (2018-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v2.3.0...v2.3.1)

**Merged pull requests:**

- allow puppetlabs/stdlib 5.x [\#106](https://github.com/voxpupuli/puppet-extlib/pull/106) ([bastelfreak](https://github.com/bastelfreak))

## [v2.3.0](https://github.com/voxpupuli/puppet-extlib/tree/v2.3.0) (2018-07-29)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v2.2.0...v2.3.0)

**Implemented enhancements:**

- Allow default\_content to render epp templates [\#103](https://github.com/voxpupuli/puppet-extlib/pull/103) ([smortex](https://github.com/smortex))

## [v2.2.0](https://github.com/voxpupuli/puppet-extlib/tree/v2.2.0) (2018-07-24)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v2.1.0...v2.2.0)

**Implemented enhancements:**

- Add sort\_by\_version function [\#99](https://github.com/voxpupuli/puppet-extlib/pull/99) ([alexjfisher](https://github.com/alexjfisher))

## [v2.1.0](https://github.com/voxpupuli/puppet-extlib/tree/v2.1.0) (2018-06-16)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v2.0.1...v2.1.0)

**Implemented enhancements:**

- Add has\_module function [\#92](https://github.com/voxpupuli/puppet-extlib/pull/92) ([alexjfisher](https://github.com/alexjfisher))

**Merged pull requests:**

- Remove docker nodesets [\#96](https://github.com/voxpupuli/puppet-extlib/pull/96) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#94](https://github.com/voxpupuli/puppet-extlib/pull/94) ([bastelfreak](https://github.com/bastelfreak))

## [v2.0.1](https://github.com/voxpupuli/puppet-extlib/tree/v2.0.1) (2017-12-18)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v2.0.0...v2.0.1)

**Merged pull requests:**

- declare compatible with Puppet 5.x [\#89](https://github.com/voxpupuli/puppet-extlib/pull/89) ([mmoll](https://github.com/mmoll))

## [v2.0.0](https://github.com/voxpupuli/puppet-extlib/tree/v2.0.0) (2017-10-11)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v1.1.0...v2.0.0)

**Fixed bugs:**

- Fix stdlib version requirement in metadata [\#83](https://github.com/voxpupuli/puppet-extlib/pull/83) ([oranenj](https://github.com/oranenj))

## [v1.1.0](https://github.com/voxpupuli/puppet-extlib/tree/v1.1.0) (2017-01-13)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v1.0.0...v1.1.0)

**Merged pull requests:**

- Bump min version\_requirement for Puppet + dep [\#75](https://github.com/voxpupuli/puppet-extlib/pull/75) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Add missing badges [\#70](https://github.com/voxpupuli/puppet-extlib/pull/70) ([dhoppe](https://github.com/dhoppe))

## [v1.0.0](https://github.com/voxpupuli/puppet-extlib/tree/v1.0.0) (2016-08-19)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.11.3...v1.0.0)

**Closed issues:**

- Unit tests are spread across 2 directories [\#60](https://github.com/voxpupuli/puppet-extlib/issues/60)
- ip\_to\_cron needs unit tests [\#59](https://github.com/voxpupuli/puppet-extlib/issues/59)
- please make a fresh release [\#54](https://github.com/voxpupuli/puppet-extlib/issues/54)

**Merged pull requests:**

- typo [\#65](https://github.com/voxpupuli/puppet-extlib/pull/65) ([mmckinst](https://github.com/mmckinst))
- Add better ip\_to\_cron unit tests [\#62](https://github.com/voxpupuli/puppet-extlib/pull/62) ([alexjfisher](https://github.com/alexjfisher))
- Move function spec tests [\#61](https://github.com/voxpupuli/puppet-extlib/pull/61) ([alexjfisher](https://github.com/alexjfisher))

## [v0.11.3](https://github.com/voxpupuli/puppet-extlib/tree/v0.11.3) (2016-04-17)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.11.2...v0.11.3)

**Merged pull requests:**

- bump again [\#56](https://github.com/voxpupuli/puppet-extlib/pull/56) ([bastelfreak](https://github.com/bastelfreak))

## [v0.11.2](https://github.com/voxpupuli/puppet-extlib/tree/v0.11.2) (2016-04-17)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.11.1...v0.11.2)

## [v0.11.1](https://github.com/voxpupuli/puppet-extlib/tree/v0.11.1) (2016-04-17)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.11.0...v0.11.1)

**Closed issues:**

- import ip\_to\_cron [\#48](https://github.com/voxpupuli/puppet-extlib/issues/48)

**Merged pull requests:**

- Release 0.11.1 [\#55](https://github.com/voxpupuli/puppet-extlib/pull/55) ([jyaworski](https://github.com/jyaworski))
- Fixes GH-48: Import ip\_to\_cron.rb from theforeman/puppet-puppet [\#52](https://github.com/voxpupuli/puppet-extlib/pull/52) ([jyaworski](https://github.com/jyaworski))
- Pin rake to avoid rubocop/rake 11 incompatibility [\#51](https://github.com/voxpupuli/puppet-extlib/pull/51) ([roidelapluie](https://github.com/roidelapluie))
- rename puppet\[ -\]?community -\> voxpupuli [\#47](https://github.com/voxpupuli/puppet-extlib/pull/47) ([igalic](https://github.com/igalic))
- chore\(sync\) ensure Rakefile and Gemfile are msynced [\#46](https://github.com/voxpupuli/puppet-extlib/pull/46) ([igalic](https://github.com/igalic))
- Added dump\_args statement function for debugging puppet code [\#30](https://github.com/voxpupuli/puppet-extlib/pull/30) ([logicminds](https://github.com/logicminds))

## [v0.11.0](https://github.com/voxpupuli/puppet-extlib/tree/v0.11.0) (2015-12-31)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.10.7...v0.11.0)

**Merged pull requests:**

- Release PR for version 0.11.0 [\#45](https://github.com/voxpupuli/puppet-extlib/pull/45) ([rnelson0](https://github.com/rnelson0))
- fix\(default\_content\) don't call template\(\) on empty template\_name [\#44](https://github.com/voxpupuli/puppet-extlib/pull/44) ([igalic](https://github.com/igalic))

## [v0.10.7](https://github.com/voxpupuli/puppet-extlib/tree/v0.10.7) (2015-12-29)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.10.6...v0.10.7)

**Merged pull requests:**

- feat \(release\) more solid way to release \(thru travis\) [\#42](https://github.com/voxpupuli/puppet-extlib/pull/42) ([igalic](https://github.com/igalic))

## [v0.10.6](https://github.com/voxpupuli/puppet-extlib/tree/v0.10.6) (2015-12-22)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.10.5...v0.10.6)

## [v0.10.5](https://github.com/voxpupuli/puppet-extlib/tree/v0.10.5) (2015-12-21)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.10.3...v0.10.5)

**Closed issues:**

- document default\_content function [\#36](https://github.com/voxpupuli/puppet-extlib/issues/36)
- New Release [\#20](https://github.com/voxpupuli/puppet-extlib/issues/20)

**Merged pull requests:**

- prepare for 0.10.5 release [\#38](https://github.com/voxpupuli/puppet-extlib/pull/38) ([igalic](https://github.com/igalic))
- docs \(default\_content\) align rdoc and readme [\#37](https://github.com/voxpupuli/puppet-extlib/pull/37) ([igalic](https://github.com/igalic))
- prep 0.10.4 release [\#35](https://github.com/voxpupuli/puppet-extlib/pull/35) ([igalic](https://github.com/igalic))
- feat \(release\) travis\_release now creates -rc version [\#34](https://github.com/voxpupuli/puppet-extlib/pull/34) ([igalic](https://github.com/igalic))
- Puppet 4-safe function calls [\#31](https://github.com/voxpupuli/puppet-extlib/pull/31) ([igalic](https://github.com/igalic))
- fixing 2 typos that bugged me in the readme [\#29](https://github.com/voxpupuli/puppet-extlib/pull/29) ([ApisMellow](https://github.com/ApisMellow))
- Add default\_content function [\#4](https://github.com/voxpupuli/puppet-extlib/pull/4) ([alvagante](https://github.com/alvagante))

## [v0.10.3](https://github.com/voxpupuli/puppet-extlib/tree/v0.10.3) (2015-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.10.2...v0.10.3)

## [v0.10.2](https://github.com/voxpupuli/puppet-extlib/tree/v0.10.2) (2015-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/0.10.1...v0.10.2)

## [0.10.1](https://github.com/voxpupuli/puppet-extlib/tree/0.10.1) (2015-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.10.1...0.10.1)

## [v0.10.1](https://github.com/voxpupuli/puppet-extlib/tree/v0.10.1) (2015-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.10.0...v0.10.1)

## [v0.10.0](https://github.com/voxpupuli/puppet-extlib/tree/v0.10.0) (2015-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.9.3...v0.10.0)

**Closed issues:**

- deployment, how does it work!? [\#10](https://github.com/voxpupuli/puppet-extlib/issues/10)

**Merged pull requests:**

- prepare release of 0.10.0 [\#27](https://github.com/voxpupuli/puppet-extlib/pull/27) ([igalic](https://github.com/igalic))
- fix Rubocop complaints + rspec deprecations [\#26](https://github.com/voxpupuli/puppet-extlib/pull/26) ([igalic](https://github.com/igalic))
- rubcop:auto\_correct [\#24](https://github.com/voxpupuli/puppet-extlib/pull/24) ([igalic](https://github.com/igalic))
- Add random\_password function to generate alphanumeric passwords [\#19](https://github.com/voxpupuli/puppet-extlib/pull/19) ([ehelms](https://github.com/ehelms))
- Add "echo" function for debugging [\#18](https://github.com/voxpupuli/puppet-extlib/pull/18) ([dmitryilyin](https://github.com/dmitryilyin))
- Adds cache\_data function for caching values on the master [\#17](https://github.com/voxpupuli/puppet-extlib/pull/17) ([ehelms](https://github.com/ehelms))
- "Update Readme for puppet- namechange" [\#16](https://github.com/voxpupuli/puppet-extlib/pull/16) ([nibalizer](https://github.com/nibalizer))
- "Enable metadata.json linting" [\#15](https://github.com/voxpupuli/puppet-extlib/pull/15) ([nibalizer](https://github.com/nibalizer))
- Check functions against stdlib [\#13](https://github.com/voxpupuli/puppet-extlib/pull/13) ([nibalizer](https://github.com/nibalizer))
- document \(and simplify\) release process [\#12](https://github.com/voxpupuli/puppet-extlib/pull/12) ([igalic](https://github.com/igalic))
- further distill matrix, following @camptocamp's example [\#11](https://github.com/voxpupuli/puppet-extlib/pull/11) ([igalic](https://github.com/igalic))

## [v0.9.3](https://github.com/voxpupuli/puppet-extlib/tree/v0.9.3) (2015-03-17)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.9.2...v0.9.3)

**Merged pull requests:**

- rename module in README, also. [\#9](https://github.com/voxpupuli/puppet-extlib/pull/9) ([igalic](https://github.com/igalic))
- no email plz [\#8](https://github.com/voxpupuli/puppet-extlib/pull/8) ([nibalizer](https://github.com/nibalizer))
- our forge name is puppet, not puppetcommunity! [\#7](https://github.com/voxpupuli/puppet-extlib/pull/7) ([igalic](https://github.com/igalic))
- test more puppet versions [\#6](https://github.com/voxpupuli/puppet-extlib/pull/6) ([igalic](https://github.com/igalic))

## [v0.9.2](https://github.com/voxpupuli/puppet-extlib/tree/v0.9.2) (2015-03-16)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.9.1...v0.9.2)

**Merged pull requests:**

- Set up autodeployment [\#5](https://github.com/voxpupuli/puppet-extlib/pull/5) ([nibalizer](https://github.com/nibalizer))
- Fix name for puppetlabs/stdlib in metadata.json [\#3](https://github.com/voxpupuli/puppet-extlib/pull/3) ([antaflos](https://github.com/antaflos))

## [v0.9.1](https://github.com/voxpupuli/puppet-extlib/tree/v0.9.1) (2014-09-03)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/v0.9.0...v0.9.1)

**Closed issues:**

- spec tests to 3.0 [\#2](https://github.com/voxpupuli/puppet-extlib/issues/2)

**Merged pull requests:**

- Improve function documentation by simplifying it [\#1](https://github.com/voxpupuli/puppet-extlib/pull/1) ([antaflos](https://github.com/antaflos))

## [v0.9.0](https://github.com/voxpupuli/puppet-extlib/tree/v0.9.0) (2014-09-02)

[Full Changelog](https://github.com/voxpupuli/puppet-extlib/compare/977744d6d05ed5801a20aa9672a80cced1092d00...v0.9.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
