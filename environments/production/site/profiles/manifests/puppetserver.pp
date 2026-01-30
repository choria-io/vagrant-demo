class profiles::puppetserver {
  # Desabilita firewall para ambiente de laboratório
  service { 'firewalld':
    ensure => stopped,
    enable => false,
  }

  include puppetdb

  class { 'puppet':
    server                => true,
    server_reports        => 'puppetdb',
    server_foreman        => false,
    server_external_nodes => '',
    runmode               => 'unmanaged',
    codedir               => '/etc/puppetlabs/code',
    server_envs_dir       => '/etc/puppetlabs/code/environments',
  }

  class { 'puppet::server::puppetdb':
    server => 'puppet.choria',
  }
}
