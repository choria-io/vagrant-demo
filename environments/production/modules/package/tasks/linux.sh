#!/bin/bash

# example: bolt task run package::linux action=install name=rsyslog

# Exit with an error message and error code, defaulting to 1
fail() {
  # Print a message: entry if there were anything printed to stderr
  if [[ -s $_tmp ]]; then
    # Hack to try and output valid json by replacing newlines with spaces.
    error_data="{ \"msg\": \"$(tr '\n' ' ' <$_tmp)\", \"kind\": \"bash-error\", \"details\": {} }"
  else
    error_data="{ \"msg\": \"Task error\", \"kind\": \"bash-error\", \"details\": {} }"
  fi
  echo "{ \"status\": \"failure\", \"_error\": $error_data }"
  exit ${2:-1}
}

success() {
  echo "$1"
  exit 0
}

validation_error() {
  error_data="{ \"msg\": \""$1"\", \"kind\": \"bash-error\", \"details\": {} }"
  echo "{ \"status\": \"failure\", \"_error\": $error_data }"
  exit 255
}

# Keep stderr in a temp file.  Easier than `tee` or capturing process substitutions
_tmp="$(mktemp)"
exec 2>"$_tmp"

action="$PT_action"
name="$PT_name"
version="$PT_version"
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

    # Use --showformat to make a json object with status and version
    # ${name%%=*} removes the version in case we installed a specific one
    # This will print nothing to stdout if the package is not installed
    case "$action" in
      "uninstall")
        action="remove"
        ;;
      "upgrade")
        action="install"
        options+=("--only-upgrade")
        old_version="$(dpkg-query --show --showformat='"${Version}"' ${name%%=*})"
    esac

    [[ $action == "status" ]] || DEBIAN_FRONTEND=noninteractive "apt-get" "$action" "$name" "${options[@]}" >/dev/null || fail

    # uninstall: do not print any version information
    if [ "$PT_action" == 'uninstall' ]; then
      cmd_status="$(dpkg-query --show --showformat='{ "status":"${Status}" }' ${name%%=*})"
      [[ $cmd_status ]] || cmd_status='{ "status": "uninstalled"}'
      success "$cmd_status"
    fi

    # upgrade: only show version information
    if [ "$PT_action" == 'upgrade' ]; then
      new_version="$(dpkg-query --show --showformat='"${Version}"' ${name%%=*})"
      cmd_status="{ \"old_version\":"${old_version}", \"version\":"${new_version}" }"
      success "$cmd_status"
    fi

    # Determine if newer package is available to mirror the ruby/puppet implementation
    installed="$(apt-cache policy $PT_name | grep 'Installed:')"
    installed="${installed#*: }"

    candidate="$(apt-cache policy $PT_name | grep 'Candidate:')"
    candidate="${candidate#*: }"
    
    if [[ $installed != $candidate ]]; then
      pkg_status="$(dpkg-query --show --showformat='"${Status}"' ${name%%=*})"
      pkg_version="$(dpkg-query --show --showformat='"${Version}"' ${name%%=*})"
      cmd_status="{ \"status\":"${pkg_status}", \"version\":"${pkg_version}", \"latest\":\""${candidate}"\" }"
    else
      cmd_status="$(dpkg-query --show --showformat='{ "status":"${Status}", "version":"${Version}" }' ${name%%=*})"
    fi

    [[ $cmd_status ]] || cmd_status='{ "status": "uninstalled", "version": "" }'
    success "$cmd_status"
    ;;

  "yum")
    # assume yes
    options+=("-y")

    # <package>-<version> is the syntax for installing a specific version in yum
    [[ $version ]] && name="${name}-${version}"

    # Use --queryformat to make a json object with status and version
    # yum is ok with including the version in the package name
    # yum returns non-zero if the package isn't installed
    case "$action" in
      "uninstall")
        action="remove"
        ;;
      "upgrade")
        possible_version="$(rpm -q --whatprovides "$name")" || possible_version="uninstalled"
        if [ "$possible_version" == "uninstalled" ]; then
          old_version="\"uninstalled\""
        else
          old_version="$(rpm -q --queryformat '"%{VERSION}"' "$possible_version")"
        fi
    esac

    [[ $action == "status" ]] || "yum" "$action" "$name" "${options[@]}" >/dev/null || fail

    # yum install <pkg> and rpm -q <pkg> may produce different results because one package may provide another
    # For example, 'vim' can be installed because the 'vim-enhanced' package provides 'vim'
    # So, find out the exact package to get the status for
    package="$(rpm -q --whatprovides "$name")"

    # uninstall: do not print any version information
    if [ "$PT_action" == 'uninstall' ]; then
      rpm_status="$(rpm -q "$package")"
      cmd_status="{ \"status\": \"$rpm_status\"}"
      [[ $cmd_status ]] || cmd_status='{ "status": "uninstalled"}'
      success "$cmd_status"
    fi

    # upgrade: only show version information
    if [ "$PT_action" == 'upgrade' ]; then
      new_version="$(rpm -q --queryformat '"%{VERSION}"' "$package")" || new_version="\"uninstalled\""
      cmd_status="{ \"old_version\":"${old_version}", \"version\":"${new_version}" }"
      success "$cmd_status"
    fi

    # Determine if newer package is available to mirror the ruby/puppet implementation
    upgradable_list=($(yum check-update --quiet "${PT_name}"))
    upgradable="${upgradable_list[@]}"
    if [ -n "${upgradable}" ]; then
      if rpm -q --whatprovides "$name" &>/dev/null; then
        pkg_version="$(rpm -q --queryformat '"%{VERSION}"' "$package")"
        cmd_status="{ \"status\":\"installed\", \"version\":"${pkg_version}", \"latest\":\""${upgradable}"\" }"
      else
        cmd_status='{ "status": "uninstalled", "version": "" }'
      fi
    else
      cmd_status="$(rpm -q --queryformat '\{ "status": "installed", "version": "%{VERSION}" \}' "$package")" || {
         cmd_status='{ "status": "uninstalled", "version": "" }'
      }
    fi

    success "$cmd_status"
esac
