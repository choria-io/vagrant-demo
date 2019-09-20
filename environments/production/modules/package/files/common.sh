#!/bin/bash

# TODO: helper task?

# Exit with an error message and error code, defaulting to 1
fail() {
  # Print a message: entry if there were anything printed to stderr
  if [[ -s $_tmp ]]; then
    # Hack to try and output valid json by replacing newlines with spaces.
    error_data="{ \"msg\": \"$(tr '\n' ' ' <"$_tmp")\", \"kind\": \"bash-error\", \"details\": {} }"
  else
    error_data="{ \"msg\": \"Task error\", \"kind\": \"bash-error\", \"details\": {} }"
  fi
  echo "{ \"status\": \"failure\", \"_error\": $error_data }"
  exit ${2:-1}
}

validation_error() {
  error_data="{ \"msg\": \""$1"\", \"kind\": \"bash-error\", \"details\": {} }"
  echo "{ \"status\": \"failure\", \"_error\": $error_data }"
  exit 255
}

success() {
  echo "$1"
  exit 0
}

# Test for colors. If unavailable, unset variables are ok
if tput colors &>/dev/null; then
  green="$(tput setaf 2)"
  red="$(tput setaf 1)"
  reset="$(tput sgr0)"
fi

_tmp="$(mktemp)"
exec 2>>"$_tmp"

# Use indirection to munge PT_ environment variables
# e.g. "$PT_version" becomes "$version"
for v in ${!PT_*}; do
  declare "${v#*PT_}"="${!v}"
done
