# run a test task
require 'spec_helper_acceptance'

describe 'package task' do
  describe 'install' do
    before(:all) do
      apply_manifest('package { "pry": ensure => absent, provider => "puppet_gem", }')
    end
    it 'installs pry', unless: (fact('operatingsystem') == 'windows') do
      result = run_task(task_name: 'package', params: 'action=install name=pry provider=puppet_gem')
      expect_multiple_regexes(result: result, regexes: [%r{installed}, %r{version.*\d+.\d+}, %r{(Job completed. 1/1 nodes succeeded|Ran on 1 node)}])
    end
    it 'returns the version of pry', unless: (fact('operatingsystem') == 'windows') do
      result = run_task(task_name: 'package', params: 'action=status name=pry provider=puppet_gem')
      expect_multiple_regexes(result: result, regexes: [%r{up to date}, %r{(Job completed. 1/1 nodes succeeded|Ran on 1 node)}])
    end
  end
  describe 'uninstall' do
    before(:all) do
      apply_manifest('package { "pry": ensure => "present", provider => "puppet_gem", }')
    end

    it 'uninstalls pry' do
      result = run_task(task_name: 'package', params: 'action=uninstall name=pry provider=puppet_gem')
      expect_multiple_regexes(result: result, regexes: [%r{uninstalled}, %r{(Job completed. 1/1 nodes succeeded|Ran on 1 node)}])
    end
    it 'status' do
      result = run_task(task_name: 'package', params: 'action=status name=pry provider=puppet_gem')
      expect_multiple_regexes(result: result, regexes: [%r{absent}, %r{(Job completed. 1/1 nodes succeeded|Ran on 1 node)}])
    end
  end
  describe 'upgrade', if: (fact('operatingsystem') == 'CentOS' && fact('operatingsystemmajrelease') == '7' && pe_install?) do
    it 'upgrade httpd to a specific version' do
      result = run_task(task_name: 'package', params: 'action=upgrade name=httpd version=2.4.6-45.el7.centos')
      expect_multiple_regexes(result: result, regexes: [%r{version : 2.4.6-45.el7.centos}, %r{Job completed. 1/1 nodes succeeded}])
    end

    it 'upgrade httpd' do
      result = run_task(task_name: 'package', params: 'action=upgrade name=httpd')
      expect_multiple_regexes(result: result, regexes: [%r{version : 2.4.6-45.el7.centos.4}, %r{old_version : 2.4.6-45.el7.centos}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
end
