class profiles::puppetserver {
  include puppetdb

  class{"puppet":
    server => true,
    server_reports => "puppetdb",
    server_foreman => false,
    server_external_nodes => "",  
    runmode => "unmanaged",
    codedir => "/vagrant",
    server_envs_dir => "/vagrant/environments"
  }

  class{"puppet::server::puppetdb":
    server => "puppet.choria",
  }
}
