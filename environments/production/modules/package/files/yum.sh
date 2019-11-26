#!/bin/bash

# $1 = string literal to feed to rpm -q. include json formatting
# Use --queryformat to make a json object with status and version
# yum returns non-zero if the package isn't installed
yum_status() {
  rpm -q --queryformat "$1" "$provided_package"
}

# Determine if newer package is available to mirror the ruby/puppet implementation
yum_check_latest() {
  installed="$(yum_status "%{VERSION}-%{RELEASE}" "$provided_package")" || success '{ "status": "uninstalled", "version": "" }'
  candidate=($(yum check-update --quiet "${name}"))

  # format of check-update is <package_name> <release>
  # i.e rpm.x86_64 4.11.3-35.el7
  if [[ $candidate && $installed != ${candidate[1]} ]]; then
    cmd_status="$(yum_status \
      "{ \"status\": \"installed\", \"version\": \"$installed\", \"latest\": \"${candidate[1]}\" \}")"
  else
      cmd_status="$(yum_status '\{ "status": "installed", "version": "%{VERSION}-%{RELEASE}" \}')" || {
        cmd_status='{ "status": "uninstalled", "version": "" }'
      }
  fi

  success "$cmd_status"
}
