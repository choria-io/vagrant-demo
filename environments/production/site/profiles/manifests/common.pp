class profiles::common {
  include mcollective
  include prometheus::node_exporter

  file{["/var/lib/node_exporter", "/var/lib/node_exporter/textfile"]:
    ensure => directory,
    owner  => node-exporter,
    group  => node-exporter
  }

  lookup("checks", Hash, "deep").each |$check, $properties| {
    choria::scout_check{$check:
      * => $properties
    }
  }

  lookup("extra_packages", Array[String], "unique").each |$package| {
    package{$package:
      ensure => present
    }
  }
}
