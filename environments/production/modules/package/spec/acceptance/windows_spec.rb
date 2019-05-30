# run a test task
require 'spec_helper_acceptance'

describe 'windows package task', if: os[:family] == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def bolt_config
    { 'modulepath' => RSpec.configuration.module_path }
  end

  let(:bolt_inventory) { hosts_to_inventory.merge('features' => ['puppet-agent']) }

  package_to_use = 'notepadplusplus.install'
  before(:all) do
    on(default, 'cmd.exe /c puppet module install puppetlabs-chocolatey')
    apply_manifest_on(default, 'include chocolatey')
  end

  describe 'install action' do
    it "install #{package_to_use}" do
      apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => absent, }")
      result = run_task('package::windows', 'default', 'action' => 'install', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{Install})
      expect(result[0]['result']).to include('version')
    end
  end

  describe 'uninstall action' do
    it "uninstall #{package_to_use}" do
      apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
      result = run_task('package::windows', 'default', 'action' => 'uninstall', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{Uninstall})
    end
  end

  describe 'install specific' do
    it 'upgrade notepad++ to a specific version' do
      result = run_task('package::windows', 'default', 'action' => 'upgrade', 'name' => package_to_use, 'version' => '7.5.5')
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{Upgrade})
      expect(result[0]['result']).to include('old_version')
      expect(result[0]['result']).to include('version')
    end

    it 'upgrade notepad++' do
      result = run_task('package::windows', 'default', 'action' => 'upgrade', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{Upgrade})
      expect(result[0]['result']).to include('old_version')
      expect(result[0]['result']).to include('version')
    end
  end

  context 'when puppet-agent feature not available on target' do
    let(:bolt_inventory) { hosts_to_inventory }

    it 'status action fails' do
      params = { 'action' => 'status', 'name' => package_to_use }
      result = run_task('package', 'default', params)
      expect(result[0]).to include('status' => 'failure')
      expect(result[0]['result']).to include('status' => 'failure')
      expect(result[0]['result']['_error']).to include('msg' => %r{'status' action not supported})
      expect(result[0]['result']['_error']).to include('kind' => 'powershell_error')
      expect(result[0]['result']['_error']).to include('details')
    end
  end
end
