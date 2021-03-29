desc "Update Choria modules"
task :update do
  modules = [
    "choria/choria",
    "choria/mcollective_data_sysctl",
    "choria/mcollective_agent_shell",
    "choria/mcollective_agent_process",
    "choria/mcollective_agent_nettest",
    "choria/mcollective_agent_bolt_tasks",
    "choria/mcollective_data_sysctl",
    "puppetlabs/apply",
    "puppetlabs/package",
    "herculesteam/augeasproviders_core",
    "camptocamp/augeas",
    "puppetlabs/puppetdb",
    "camptocamp/systemd",
    "puppet/archive",
    "puppet/prometheus",
    "theforeman/puppet",
    "puppetlabs/puppet_authorization",
  ]

  rm_rf "environments/production/modules"
  mkdir_p "environments/production/modules"

  sh "puppet module install --modulepath `pwd`/environments/production/modules puppetlabs/concat --version 6.4.0"

  modules.each do |mod|
    sh "puppet module install --modulepath `pwd`/environments/production/modules %s" % mod
  end
end
