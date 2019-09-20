#!/bin/bash

# example: bolt task run package::linux action=install name=rsyslog

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

declare PT__installdir
source "$PT__installdir/package/files/common.sh"

package_managers=("apt-get" "yum")
options=()

for p in "${package_managers[@]}"; do
  if type "$p" &>/dev/null; then
    available_manager="$p"
    break
  fi
done

[[ $available_manager ]] || {
  validation_error "No package managers found: Must be one of: [apt, yum]"
}

# For any package manager, check if the action is "status". If so, only run a status command
# Otherwise, run the requested action and follow up with a "status" command
case "$available_manager" in
  "apt-get")
    # quiet and assume yes
    options+=("-yq")

    # <package>=<version> is the syntax for installing a specific version in apt
    [[ $version ]] && name="${name}=${version}"

    # For Ruby compatability, 'status' and 'install' will check if the package is upgradable
    case "$action" in
      "status")
        apt_check_latest
      ;;

    "install")
        apt-get install "$name" "${options[@]}" >/dev/null || fail
        apt_check_latest
      ;;

      # uninstall: do not print any version information
      "uninstall")
        apt-get remove "$name" "${options[@]}" >/dev/null || fail
        cmd_status="$(apt_status '{ "status":"${Status}" }')" || cmd_status='{ "status": "uninstalled" }'
        success "$cmd_status"
        ;;

      "upgrade")
        action="install"
        options+=("--only-upgrade")
        # Get the currently installed version to compare with the upgraded version
        old_version="$(apt_status '"${Version}"')"

        apt-get install "$name" "${options[@]}" >/dev/null || fail
        # For Ruby compatability, this command uses a different output format
        cmd_status="$(apt_status "{ \"old_version\": ${old_version}, \"version\": \"\${Version}\" }")"
        success "$cmd_status"
    esac
    ;;
  "yum")
    # assume yes
    options+=("-y")

    # yum install <pkg> and rpm -q <pkg> may produce different results because one package may provide another
    # For example, 'vim' can be installed because the 'vim-enhanced' package provides 'vim'
    # So, find out the exact package to get the status for
    provided_package="$(rpm -q --whatprovides "$name")" || provided_package=

    # <package>-<version> is the syntax for installing a specific version in yum
    [[ $version ]] && name="${name}-${version}"

    # For Ruby compatibility, 'status' and 'install' will check if the package is upgradable
    case "$action" in
      "status")
        yum_check_latest
        ;;

      "install")
        yum install "$name" "${options[@]}" >/dev/null || fail
        # Check for this again after installing
        provided_package="$(rpm -q --whatprovides "$name")" || provided_package=
        yum_check_latest
        ;;

      "uninstall")
        yum remove "$name" "${options[@]}" >/dev/null || fail
        cmd_status="$(yum_status '\{ "status": "installed", "version": "%{VERSION}-%{RELEASE}" \}')" || {
          cmd_status='{ "status": "uninstalled" }'
        }
        success "$cmd_status"
        ;;

      "upgrade")
        if [[ $provided_package ]]; then
          old_version="$(yum_status '"%{VERSION}-%{RELEASE}"')"
        else
          old_version='"uninstalled"'
        fi

        # Why does yum upgrade not return non-zero on a nonexistent package...
        # Because of this, check the output
        yum_out=$(yum upgrade "$name" "${options[@]}") || fail
        [[ $yum_out =~ "No package $name available" ]] && fail

        # For Ruby compatibility, this command uses a different output format
        # Check for this again after installing
        provided_package="$(rpm -q --whatprovides "$name")" || provided_package=
        cmd_status="$(yum_status "\{ \"old_version\": ${old_version}, \"version\": \"%{VERSION}-%{RELEASE}\" \}")"
        success "$cmd_status"
    esac
esac
