# run a test task
require 'spec_helper_acceptance'

describe 'windows package task', if: os[:family] == 'windows' do
  package_to_use = 'notepadplusplus.install'
  target_host = ENV['TARGET_HOST']
  before(:all) do
    command_string = 'cmd.exe /c puppet module install puppetlabs-chocolatey'
    command_string << " --modulepath #{Dir.pwd}/spec/fixtures/modules" if target_host.nil? || target_host == 'localhost'
    run_shell(command_string)
    pp = <<-PUPPETCODE
    include chocolatey
PUPPETCODE
    apply_manifest(pp)
  end

  describe 'install action' do
    it "install #{package_to_use}" do
      apply_manifest("package { \"#{package_to_use}\": ensure => absent,  }")
      result = run_bolt_task('package::windows', 'action' => 'install', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{Install})
      expect(result['result']).to include('version')
    end
  end

  describe 'uninstall action' do
    it "uninstall #{package_to_use}" do
      apply_manifest("package { \"#{package_to_use}\": ensure => present, provider => 'chocolatey' }")
      result = run_bolt_task('package::windows', 'action' => 'uninstall', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{Uninstall})
    end
  end

  describe 'install specific' do
    it 'upgrade notepad++ to a specific version' do
      result = run_bolt_task('package::windows', 'action' => 'upgrade', 'name' => package_to_use, 'version' => '7.5.5')
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{Upgrade})
      expect(result['result']).to include('old_version')
      expect(result['result']).to include('version')
    end

    it 'upgrade notepad++' do
      result = run_bolt_task('package::windows', 'action' => 'upgrade', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{Upgrade})
      expect(result['result']).to include('old_version')
      expect(result['result']).to include('version')
    end
  end

  context 'when puppet-agent feature not available on target', if: target_host != 'localhost' && os[:family] == 'windows' do
    it 'status action fails' do
      inventory_hash = inventory_hash_from_inventory_file
      inventory_hash = remove_feature_from_node(inventory_hash, 'puppet-agent', target_host)
      inventory_hash = remove_feature_from_node(inventory_hash, 'puppet-agent', 'local')
      temp_inventory_file = "#{ENV['TARGET_HOST']}.yaml"
      write_to_inventory_file(inventory_hash, temp_inventory_file)
      params = { 'action' => 'status', 'name' => package_to_use }
      options = { inventory_file: temp_inventory_file }
      expect { run_bolt_task('package', params, options) }.to raise_error(RuntimeError)
      result = run_bolt_task('package', params, expect_failures: true, inventory_file: temp_inventory_file)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{'status' action not supported})
      expect(result['result']['_error']).to include('kind' => 'powershell_error')
      expect(result['result']['_error']).to include('details')
      File.delete(temp_inventory_file) if File.exist?(temp_inventory_file)
    end
  end
end
