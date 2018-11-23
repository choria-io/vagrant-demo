# run a test task
require 'spec_helper_acceptance'

describe 'windows package task', if: fact('osfamily') == 'windows' do
  package_to_use = 'notepadplusplus.install'
  before(:all) do
    hosts.each do |host|
      on(host, 'cmd.exe /c puppet module install puppetlabs-chocolatey')
      apply_manifest('include chocolatey')
    end
  end
  describe 'install action' do
    it "install #{package_to_use}" do
      apply_manifest("package { \"#{package_to_use}\": ensure => absent, }")
      result = run_task(task_name: 'package::windows', params: "action=install name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{install}, %r{success}, %r{Ran on 1 node}])
    end
  end
  describe 'uninstall action' do
    it "uninstall #{package_to_use}" do
      apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
      result = run_task(task_name: 'package::windows', params: "action=uninstall name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{install}, %r{success}, %r{Ran on 1 node}])
    end
  end
  describe 'install specific' do
    it 'upgrade notepad++ to a specific version' do
      result = run_task(task_name: 'package::windows', params: "action=upgrade name=#{package_to_use} version=7.5.5")
      expect_multiple_regexes(result: result, regexes: [%r{upgrade}, %r{success}, %r{Ran on 1 node}])
    end

    it 'upgrade notepad++' do
      result = run_task(task_name: 'package::windows', params: "action=upgrade name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{upgrade}, %r{success}, %r{Ran on 1 node}])
    end
  end
end
