# run a test task
require 'spec_helper_acceptance'

# Red-Hat 6 is the only platform we cannot reliably perform package actions on
redhat_six = os[:family] == 'redhat' && os[:release].to_i == 6
windows = os[:family] == 'windows'

describe 'linux package task', unless: redhat_six || windows do
  describe 'install action' do
    it 'installs rsyslog' do
      apply_manifest("package { 'rsyslog': ensure => absent, }")
      result = run_bolt_task('package::linux', 'action' => 'install', 'name' => 'rsyslog')
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{install})
      expect(result['result']).to include('version')
    end

    it 'errors gracefully when bogus package requested' do
      result = run_bolt_task('package::linux', { 'action' => 'install', 'name' => 'foo' }, expect_failures: true)
      # older EL platforms may report that the bogus package is uninstalled,
      if result['result']['status'] == 'failure'
        expect(result['result']).to include('status' => 'failure')
        expect(result['result']['_error']).to include('msg')
        expect(result['result']['_error']).to include('kind' => 'bash-error')
        expect(result['result']['_error']).to include('details')
      elsif result['result']['status'] == 'success' || result['result']['status'] == 'uninstalled'
        expect(result['result']).to include('status' => 'uninstalled')
      else
        raise "Unexpected result: #{result}"
      end
    end
  end

  describe 'status action' do
    it 'status rsyslog' do
      apply_manifest("package { 'rsyslog': ensure => present, }")
      result = run_bolt_task('package::linux', 'action' => 'status', 'name' => 'rsyslog')
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{install})
      expect(result['result']).to include('version')
    end
  end

  describe 'uninstall action' do
    it 'uninstall rsyslog' do
      apply_manifest("package { 'rsyslog': ensure => present, }")
      result = run_bolt_task('package::linux', 'action' => 'uninstall', 'name' => 'rsyslog')
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{not install|deinstall|uninstall})
    end
  end

  describe 'upgrade' do
    it 'upgrade rsyslog' do
      apply_manifest("package { 'rsyslog': ensure => present, }")
      result = run_bolt_task('package::linux', 'action' => 'upgrade', 'name' => 'rsyslog')
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('old_version')
      expect(result['result']).to include('version')
    end
  end
end
