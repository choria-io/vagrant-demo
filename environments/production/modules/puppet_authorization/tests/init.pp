puppet_authorization { '/tmp/auth_no_hdr_certinfo.conf':
  version                => 1,
  allow_header_cert_info => false,
}

puppet_authorization { '/tmp/auth_hdr_certinfo.conf':
  version                => 2,
  allow_header_cert_info => true,
}
