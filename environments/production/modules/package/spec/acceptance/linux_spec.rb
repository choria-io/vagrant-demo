# run a test task
require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'linux package task', unless: fact('osfamily') == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  let(:module_path) { RSpec.configuration.module_path }
  let(:config) { { 'modulepath' => module_path } }
  let(:inventory) { hosts_to_inventory }

  def run(params)
    run_task('package::linux', 'default', params, config: config, inventory: inventory)
  end

  redhat_six = fact('os.name') == 'RedHat' && fact('os.release.major') == '6'
  windows = fact('osfamily') == 'windows'

  describe 'install action' do
    it 'install rsyslog', unless: redhat_six || windows do
      apply_manifest_on(default, "package { 'rsyslog': ensure => absent, }")
      result = run('action' => 'install', 'name' => 'rsyslog')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{install})
    end
  end

  describe 'uninstall action', unless: redhat_six || windows do
    it 'uninstall rsyslog' do
      apply_manifest_on(default, "package { 'rsyslog': ensure => present, }")
      result = run('action' => 'uninstall', 'name' => 'rsyslog')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{uninstall})
    end
  end

  describe 'upgrade', if: (fact('operatingsystem') == 'CentOS' && fact('operatingsystemmajrelease') == '7') do
    it 'upgrade httpd' do
      apply_manifest_on(default, 'package { "httpd": ensure => "present", }')
      result = run('action' => 'upgrade', 'name' => 'httpd')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{upgrade})
    end
  end
end
