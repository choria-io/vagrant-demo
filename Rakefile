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
    "puppetlabs/inifile",
    "puppetlabs/puppet_authorization",
    "herculesteam/augeasproviders_core",
    "camptocamp/augeas",
  ]

  rm_rf "environments/production/modules"
  mkdir_p "environments/production/modules"

  modules.each do |mod|
    sh "puppet module install --modulepath `pwd`/environments/production/modules %s" % mod
  end

  sh "puppet module install --modulepath `pwd`/environments/production/modules camptocamp/puppetserver --ignore-dependencies"
end
