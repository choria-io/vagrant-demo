class profiles::common {
  include mcollective

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
