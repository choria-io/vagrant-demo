require 'bolt_spec/run'
require 'beaker-task_helper/inventory'
require 'beaker-pe'
require 'beaker-puppet'
require 'puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
configure_type_defaults_on(hosts)
install_ca_certs
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  c.add_setting :module_path
  c.module_path = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'modules')
end
