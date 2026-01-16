class profiles::puppetserver {
  include puppetdb

  class{"puppet":
    server => true,
    server_reports => "puppetdb",
    server_foreman => false,
    server_external_nodes => "",
    runmode => "unmanaged",
    codedir => "/etc/puppetlabs/code",
    server_envs_dir => "/etc/puppetlabs/code/environments"
  }

  class{"puppet::server::puppetdb":
    server => "puppet.choria",
  }

  # Firewall rule for PuppetServer
  firewall { '102 allow puppetserver':
    dport  => 8140,
    proto  => tcp,
    action => accept,
  }
}
