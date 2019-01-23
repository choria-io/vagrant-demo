# run a test task
require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'windows package task', if: fact('osfamily') == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  let(:module_path) { RSpec.configuration.module_path }
  let(:config) { { 'modulepath' => module_path } }
  let(:inventory) { hosts_to_inventory }

  def run(params)
    run_task('package::windows', 'default', params, config: config, inventory: inventory)
  end

  package_to_use = 'notepadplusplus.install'
  before(:all) do
    on(default, 'cmd.exe /c puppet module install puppetlabs-chocolatey')
    apply_manifest_on(default, 'include chocolatey')
  end

  describe 'install action' do
    it "install #{package_to_use}" do
      apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => absent, }")
      result = run('action' => 'install', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['action']).to match(%r{install})
    end
  end

  describe 'uninstall action' do
    it "uninstall #{package_to_use}" do
      apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
      result = run('action' => 'uninstall', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['action']).to match(%r{uninstall})
    end
  end

  describe 'install specific' do
    it 'upgrade notepad++ to a specific version' do
      result = run('action' => 'upgrade', 'name' => package_to_use, 'version' => '7.5.5')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['action']).to match(%r{upgrade})
    end

    it 'upgrade notepad++' do
      result = run('action' => 'upgrade', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['action']).to match(%r{upgrade})
    end
  end
end
