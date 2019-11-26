#!/bin/bash

# example: bolt task run package::linux action=install name=rsyslog

declare PT__installdir
for f in "$PT__installdir"/package/files/*sh; do
  source "$f"
done

package_managers=("apt-get" "yum" "zypper")
options=()

for p in "${package_managers[@]}"; do
  if type "$p" &>/dev/null; then
    available_manager="$p"
    break
  fi
done

[[ $available_manager ]] || {
  validation_error "No package managers found: Must be one of: [apt, yum, zypper]"
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
    ;;

  "zypper")
    # Non-interactive and no color
    options+=("-n")

    # <package>-<version> is the syntax for installing a specific version in zypper
    [[ $version ]] && name="${name}-${version}"

    case "$action" in
      "install")
        zyp_cmd="in"
        ;;

      "uninstall")
        zyp_cmd="rm"
        ;;

      # zypper won't upgrade a package if the newer version comes from a different vendor
      # So we'll use zypper in with the latest version
      "upgrade")
        # Call this to get the candidate and installed version
        zypper_status "${name%%=*}" >/dev/null
        old_version="$installed_version"

        [[ $candidate ]] && name="${name}-${candidate}"
        zyp_cmd="in"
    esac

    if [[ $zyp_cmd ]]; then
      zypper "${options[@]}" "$zyp_cmd" "$name" >/dev/null 2>"$_tmp" || fail
    fi

    # Installing and removing a specific version is ok, but not for `if`
    # So strip the version from this command
    cmd_status="$(zypper_status "${name%%-*}")"
    success "$cmd_status"
esac
