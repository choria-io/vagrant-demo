define puppet_authorization::rule (
  Optional[String] $match_request_path                                                                          = undef,
  Optional[Enum['path', 'regex']] $match_request_type                                                           = undef,
  Stdlib::Absolutepath $path,
  Enum['present', 'absent'] $ensure                                                                             = 'present',
  String $rule_name                                                                                             = $name,
  Variant[Array[Variant[String, Hash]], String, Hash, Undef] $allow                                             = undef,
  Boolean $allow_unauthenticated                                                                                = false,
  Variant[Array[Variant[String, Hash]], String, Hash, Undef] $deny                                              = undef,
  Variant[Array[Puppet_authorization::Httpmethod], Puppet_authorization::Httpmethod, Undef] $match_request_method = undef,
  Hash $match_request_query_params                                                                              = {},
  Integer $sort_order                                                                                           = 200
) {
  if $ensure == 'present' {
    if $allow_unauthenticated and ($allow or $deny) {
      fail('$allow and $deny cannot be specified if $allow_unauthenticated is true')
    } elsif ! $allow and ! $deny and ! $allow_unauthenticated {
      fail('One of $allow or $deny is required if $allow_unauthenticated is false')
    }
  }

  if $match_request_method {
    $match_request = {
      'path'         => $match_request_path,
      'type'         => $match_request_type,
      'query-params' => $match_request_query_params,
      'method'       => $match_request_method,
    }
  } else {
    $match_request = {
      'path'         => $match_request_path,
      'type'         => $match_request_type,
      'query-params' => $match_request_query_params,
    }
  }

  if $allow and $deny {
    $rule = {
      'match-request' => $match_request,
      'allow'         => $allow,
      'deny'          => $deny,
      'name'          => $rule_name,
      'sort-order'    => $sort_order,
    }
  } elsif $allow {
    $rule = {
      'match-request' => $match_request,
      'allow'         => $allow,
      'name'          => $rule_name,
      'sort-order'    => $sort_order,
    }
  } elsif $deny {
    $rule = {
      'match-request' => $match_request,
      'deny'          => $deny,
      'name'          => $rule_name,
      'sort-order'    => $sort_order,
    }
  } else {
    $rule = {
      'match-request'         => $match_request,
      'allow-unauthenticated' => $allow_unauthenticated,
      'name'                  => $rule_name,
      'sort-order'            => $sort_order,
    }
  }

  puppet_authorization_hocon_rule { "rule-${name}":
    ensure => $ensure,
    path   => $path,
    value  => $rule,
  }
}
