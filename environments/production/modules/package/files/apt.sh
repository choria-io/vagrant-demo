#!/bin/bash

# $1 = string literal to feed to dpkg-query. include json formatting
# No error check here because querying the status of uninstalled packages will return non-zero
# Use --showformat to make a json object with status and version
# ${name%%=*} removes the version in case we installed a specific one
# This will print nothing to stdout if the package is not installed
apt_status() {
  dpkg-query --show --showformat="$1" "${name%%=*}"
}

# Determine if newer package is available to mirror the ruby/puppet implementation
apt_check_latest() {
  installed="$(apt_status '${Version}')"
  [[ $installed ]] || success '{ "status": "uninstalled", "version": ""}'

  candidate="$(apt-cache policy "$name" | grep 'Candidate:')"
  candidate="${candidate#*: }"

  if [[ $installed != $candidate ]]; then
    cmd_status="$(apt_status "{ \"status\":\"\${Status}\", \"version\":\"${installed}\", \"latest\":\"${candidate}\" }")"
  else
    cmd_status="$(apt_status '{ "status":"${Status}", "version":"${Version}" }')"
  fi

  success "$cmd_status"
}
