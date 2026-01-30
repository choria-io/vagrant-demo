class profiles::network_broker {
  class { 'choria::broker':
    listen_address       => '0.0.0.0',
    stats_listen_address => '127.0.0.1',
    stats_port           => 8222,
  }
}
