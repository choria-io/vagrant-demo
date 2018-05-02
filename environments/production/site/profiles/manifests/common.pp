class profiles::common {
  include mcollective

  lookup("extra_packages", Array[String], "unique").each |$package| {
    package{$package:
      ensure => present
    }
  }
}
