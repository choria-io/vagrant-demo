# run a test task
require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'package task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  let(:module_path) { RSpec.configuration.module_path }
  let(:config) { { 'modulepath' => module_path } }
  let(:inventory) { hosts_to_inventory.merge('features' => ['puppet-agent']) }

  def run(params)
    run_task('package', 'default', params, config: config, inventory: inventory)
  end

  operating_system_fact = fact('operatingsystem')
  redhat_six = fact('os.name') == 'RedHat' && fact('os.release.major') == '6'

  describe 'install' do
    before(:all) do
      apply_manifest_on(default, 'package { "pry": ensure => absent, provider => "puppet_gem", }')
    end

    it 'installs pry', unless: (operating_system_fact == 'windows') do
      result = run('action' => 'install', 'name' => 'pry', 'provider' => 'puppet_gem')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('installed')
      expect(result[0]['result']['version']).to match(%r{\d+\.\d+\.\d+})
    end

    it 'returns the version of pry', unless: (operating_system_fact == 'windows') || redhat_six do
      result = run('action' => 'status', 'name' => 'pry', 'provider' => 'puppet_gem')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('up to date')
      expect(result[0]['result']['version']).to match(%r{\d+\.\d+\.\d+})
    end
  end

  describe 'install without puppet' do
    let(:inventory) { hosts_to_inventory }

    it 'installs rsyslog', unless: (operating_system_fact == 'windows') || redhat_six do
      result = run('action' => 'install', 'name' => 'rsyslog')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{install})
    end
  end

  describe 'uninstall' do
    before(:all) do
      apply_manifest_on(default, 'package { "pry": ensure => "present", provider => "puppet_gem", }')
    end

    it 'uninstalls pry' do
      result = run('action' => 'uninstall', 'name' => 'pry', 'provider' => 'puppet_gem')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('uninstalled')
    end
    it 'status' do
      result = run('action' => 'status', 'name' => 'pry', 'provider' => 'puppet_gem')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('absent')
    end
  end

  describe 'upgrade', if: (operating_system_fact == 'CentOS' && fact('operatingsystemmajrelease') == '7') do
    before(:all) do
      apply_manifest_on(default, 'package { "httpd": ensure => "present", }')
    end

    it 'upgrade httpd' do
      result = run('action' => 'upgrade', 'name' => 'httpd')
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['version']).to match(%r{2.4.6-\d+.el7.centos})
      expect(result[0]['result']['old_version']).to match(%r{2.4.6-\d+.el7.centos})
    end
  end
end
