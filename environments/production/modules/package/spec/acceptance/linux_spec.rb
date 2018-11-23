# run a test task
require 'spec_helper_acceptance'

describe 'linux package task', unless: fact_on(default, 'osfamily') == 'windows' do
  package_to_use = 'rsyslog'
  describe 'install action' do
    it "install #{package_to_use}" do
      apply_manifest("package { \"#{package_to_use}\": ensure => absent, }")
      result = run_task(task_name: 'package::linux', params: "action=install name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{install}, %r{(Job completed. 1/1 nodes succeeded|Ran on 1 node)}])
    end
  end
  describe 'uninstall action' do
    it "uninstall #{package_to_use}" do
      apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
      result = run_task(task_name: 'package::linux', params: "action=uninstall name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{install}, %r{(Job completed. 1/1 nodes succeeded|Ran on 1 node)}])
    end
  end
  describe 'install specific', if: (fact('operatingsystem') == 'CentOS' && fact('operatingsystemmajrelease') == '7' && pe_install?) do
    it 'upgrade httpd to a specific version' do
      result = run_task(task_name: 'package', params: 'action=upgrade name=httpd version=2.4.6-45.el7.centos')
      expect_multiple_regexes(result: result, regexes: [%r{Job completed. 1/1 nodes succeeded}])
    end

    it 'upgrade httpd' do
      result = run_task(task_name: 'package', params: 'action=upgrade name=httpd')
      expect_multiple_regexes(result: result, regexes: [%r{Job completed. 1/1 nodes succeeded}])
    end
  end
end
