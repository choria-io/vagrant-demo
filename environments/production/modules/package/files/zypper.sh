#!/bin/bash

# zypper supports xml output for parsing, but we're not guaranteed to have a parser
zypper_status() {
  installed_version

  IFS='|' read -ra package_fields < <(zypper "${options[@]}" se -s --match-exact "$1" | grep ^i)

  if ! [[ "$package_fields" ]]; then
    printf '%s' '{ "status": "uninstalled", "version": "" }'
    return
  fi

  # We can't rely on the "Status" field of zypper if to determine up-to-date-ness
  # e.g. if the newer version comes from a different vendor it will report "up-to-date"
  # So, use zypper lu and awk
  installed_version="${package_fields[3]//\ /}"
  candidate="$(zypper lu -t package --all 2>/dev/null | \
    # Strip spaces, check if the name column matches exactly, and print the available version
    awk -v package="$1" -F '|' '{gsub(" ","", $0)} $3 == package { print $5 }')"

  if [[ $candidate ]] ; then
    cmd_status="{\"status\": \"installed\", \"version\": \"$installed_version\", \"latest\": \"$candidate\"}"
  elif [[ $action == "upgrade" ]]; then
    cmd_status="{\"status\": \"installed\", \"old_version\": \"$old_version\", \"version\": \"$installed_version\"}"
  else
    cmd_status="{\"status\": \"installed\", \"version\": \"$installed_version\"}"
  fi

  printf '%s' "$cmd_status"
}
