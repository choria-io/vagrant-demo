# run a test task
require 'spec_helper_acceptance'

# Red-Hat 6 is the only platform we cannot reliably perform package actions on
redhat_six = os[:family] == 'redhat' && os[:release].to_i == 6
windows = os[:family] == 'windows'

describe 'linux package task', unless: redhat_six || windows do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def bolt_config
    { 'modulepath' => RSpec.configuration.module_path }
  end

  let(:bolt_inventory) { hosts_to_inventory.merge('features' => ['puppet-agent']) }

  describe 'install action' do
    it 'installs rsyslog' do
      apply_manifest_on(default, "package { 'rsyslog': ensure => absent, }")
      result = run_task('package::linux', 'default', 'action' => 'install', 'name' => 'rsyslog')
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{install})
      expect(result[0]['result']).to include('version')
    end

    it 'errors gracefully when bogus package requested' do
      result = run_task('package::linux', 'default', 'action' => 'install', 'name' => 'foo')
      # older EL platforms may report that the bogus package is uninstalled,
      if result[0]['status'] == 'failure'
        expect(result[0]['result']).to include('status' => 'failure')
        expect(result[0]['result']['_error']).to include('msg')
        expect(result[0]['result']['_error']).to include('kind' => 'bash-error')
        expect(result[0]['result']['_error']).to include('details')
      elsif result[0]['status'] == 'success'
        expect(result[0]['result']).to include('status' => 'uninstalled')
      else
        raise "Unexpected result: #{result}"
      end
    end
  end

  describe 'status action' do
    it 'status rsyslog' do
      apply_manifest_on(default, "package { 'rsyslog': ensure => present, }")
      result = run_task('package::linux', 'default', 'action' => 'status', 'name' => 'rsyslog')
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{install})
      expect(result[0]['result']).to include('version')
    end
  end

  describe 'uninstall action' do
    it 'uninstall rsyslog' do
      apply_manifest_on(default, "package { 'rsyslog': ensure => present, }")
      result = run_task('package::linux', 'default', 'action' => 'uninstall', 'name' => 'rsyslog')
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{not install|deinstall|uninstall})
    end
  end

  describe 'upgrade' do
    it 'upgrade rsyslog' do
      apply_manifest_on(default, "package { 'rsyslog': ensure => present, }")
      result = run_task('package::linux', 'default', 'action' => 'upgrade', 'name' => 'rsyslog')
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('old_version')
      expect(result[0]['result']).to include('version')
    end
  end
end
