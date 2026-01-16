class profiles::network_broker {
  class { 'choria::broker':
    listen_address       => '0.0.0.0',
    stats_listen_address => '127.0.0.1',
    stats_port           => 8222,
  }

  # Firewall rules for Choria Broker
  firewall { '100 allow choria broker nats':
    dport  => 4222,
    proto  => tcp,
    action => accept,
  }

  firewall { '101 allow choria broker stats':
    dport  => 8222,
    proto  => tcp,
    action => accept,
  }
}
