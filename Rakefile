desc "Update Choria modules"
task :update do
  modules = [
    "puppetlabs/stdlib",
    "choria/choria",
    "choria/mcollective_data_sysctl",
    "choria/mcollective_agent_shell",
    "choria/mcollective_agent_process",
    "choria/mcollective_agent_nettest",
    "choria/mcollective_agent_bolt_tasks",
    "choria/mcollective_data_sysctl",
    "puppetlabs/apply",
    "puppetlabs/package",
    "puppetlabs/inifile",
    "herculesteam/augeasproviders_core",
    "camptocamp/augeas",
    "puppetlabs/concat",
    "puppetlabs/puppetdb",
    "camptocamp/systemd",
    "puppet/archive",
    "puppet/prometheus",
    "puppetlabs/puppet_authorization",
    "theforeman/puppet"
  ]

  rm_rf "environments/production/modules"
  mkdir_p "environments/production/modules"

  modules.each do |mod|
    sh "puppet module install --modulepath `pwd`/environments/production/modules %s" % mod
  end
end
