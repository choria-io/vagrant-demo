#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'puppet'
# Required to find pluginsync'd plugins
Puppet.initialize_settings
require 'json'

def install(provider, version)
  if !([:absent, :purged] & Array(provider.properties[:ensure])).empty?
    provider.resource[:ensure] = version unless version.nil?
    provider.install
    provider.flush
    { status: 'installed', version: Array(provider.properties[:ensure]).join(', ') }
  else
    { status: 'present', version: Array(provider.properties[:ensure]).join(', ') }
  end
end

def status(provider, _version)
  version = Array(provider.properties[:ensure])
  if !([:absent, :purged] & version).empty?
    { status: 'absent', version: version }
  elsif provider.respond_to?(:latest)
    latest = provider.latest
    if !version.include?(latest)
      { status: 'out of date', version: version.join(', '), latest: latest }
    else
      { status: 'up to date', version: version.join(', ') }
    end
  else
    { status: 'unknown', version: version.join(', ') }
  end
end

def uninstall(provider, _version)
  if !([:absent, :purged] & Array(provider.properties[:ensure])).empty?
    { status: 'absent' }
  else
    provider.uninstall
    provider.flush
    { status: 'uninstalled' }
  end
end

def upgrade(provider, version)
  old_version = Array(provider.properties[:ensure])
  provider.resource[:ensure] = version unless version.nil?
  provider.update
  provider.flush
  { old_version: old_version.join(', '), version: Array(provider.properties[:ensure]).join(', ') }
end

params = JSON.parse(STDIN.read)
name = params['name']
provider = params['provider']
action = params['action']
version = params['version']

opts = { name: name }
opts[:provider] = provider if provider

begin
  provider = Puppet::Type.type(:package).new(opts).provider

  result = send(action, provider, version)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure',
         _error: { msg: e.message,
                   kind: 'puppet_error',
                   details: {} } }.to_json)
  exit 1
end
