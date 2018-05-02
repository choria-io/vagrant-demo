class profiles::puppetserver {
  include puppetserver

  ini_setting{"code dir":
    ensure  => present,
    path    => "/etc/puppetlabs/puppet/puppet.conf",
    section => "master",
    setting => "codedir",
    value   => "/vagrant",
  }

  ini_setting{"environment path":
    ensure  => present,
    path    => "/etc/puppetlabs/puppet/puppet.conf",
    section => "master",
    setting => "environmentpath",
    value   => "/vagrant/environments",
  }

  puppet_authorization::rule { "puppetlabs tasks file contents":
    match_request_path   => "/puppet/v3/file_content/tasks",
    match_request_type   => "path",
    match_request_method => "get",
    allow                => ["*"],
    sort_order           => 510,
    path                 => "/etc/puppetlabs/puppetserver/conf.d/auth.conf",
    notify               => Class["puppetserver::config"]
  }

  puppet_authorization::rule { "puppetlabs tasks":
    match_request_path   => "/puppet/v3/tasks",
    match_request_type   => "path",
    match_request_method => "get",
    allow                => ["*"],
    sort_order           => 510,
    path                 => "/etc/puppetlabs/puppetserver/conf.d/auth.conf",
    notify               => Class["puppetserver::config"]
  }
}
