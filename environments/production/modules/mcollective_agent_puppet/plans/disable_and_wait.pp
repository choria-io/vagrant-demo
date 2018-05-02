# Disables Puppet on the provided nodes and wait for them to idle
#
# By default 10 checks will be done 20 seconds apart, you can adjust these
# using the Playbook properties
#
# @param nodes [Choria::Nodes] The nodes to disable
# @param checks [Integer] How many checks to perform
# @param sleep [Integer] How long to wait between checks
# @param message [Optional[String]] The message to use when disabling Puppet
# @returns [Choria::TaskResults]
plan mcollective_agent_puppet::disable_and_wait (
  Choria::Nodes $nodes,
  Integer $checks = 10,
  Integer $sleep = 20,
  Optional[String] $message = undef
) {
  choria::run_playbook("mcollective_agent_puppet::disable",
    "message" => $message,
    "nodes"   => $nodes
  )

  choria::task(
    "action"    => "puppet.status",
    "nodes"     => $nodes,
    "assert"    => "idling=true",
    "tries"     => $checks,
    "try_sleep" => $sleep,
    "silent"    => true,
    "pre_sleep" => 5
  )
}
