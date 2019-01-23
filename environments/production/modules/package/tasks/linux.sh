#!/bin/bash

action="$PT_action"
name="$PT_name"
version="$PT_version"

package_managers[0]="yum"
package_managers[1]="apt-get"

# example cli /opt/puppetlabs/puppet/bin/bolt task run package::linux action=install name=vim --nodes localhost --modulepath /etc/puppetlabs/code/modules --password puppet --user root

check_command_exists() {
  (which "$1") > /dev/null 2>&1
  command_exists=$?
  return ${command_exists}
}

if [ "${action}" = "uninstall" ]; then
  action="remove"
fi

for package_manager in "${package_managers[@]}"
do
  check_command_exists "$package_manager"
  command_exists=$?
  if [ "${command_exists}" -eq 0 ]; then
    if [ "${package_manager}" = "yum" ]; then
      if [ "${version}" != "" ]; then
        name="$name-$version"
      fi
      # upgrading to a specific version needs to use the install action
      if [ "${version}" != "" ] && [ "${action}" = "upgrade" ]; then
        action="install"
      fi
    else
      $(export DEBIAN_FRONTEND=noninteractive)
      if [ "${version}" != "" ]; then
        name="$name=$version"
      fi
      # upgrading requires install to be used. --only-upgrade will not install new packages
      if [ "${action}" = "upgrade" ]; then
        action="install --only-upgrade"
      fi
    fi

    command_line="$package_manager -y $action $name"
    output=$(${command_line} 2>&1)
    status_from_command=$?
    # set up our status and exit code
    if [ "${status_from_command}" -eq 0 ]; then
      echo "{ \"status\": \"$PT_name $PT_action\" }"
      exit 0
    else
      echo "{ \"status\": \"unable to run command '$command_line'\" }"
      exit ${status_from_command}
    fi
  fi
done

echo "{ \"status\": \"No package managers found\" }"
exit 255
