# Disables Puppet on the provided nodes
#
# @param nodes [Choria::Nodes] The nodes to disable
# @param message [Optional[String]] The message to use when disabling Puppet
# @returns [Choria::TaskResults]
plan mcollective_agent_puppet::disable (
  Choria::Nodes $nodes,
  Optional[String] $message = undef
) {
  choria::task(
    "action"     => "puppet.disable",
    "nodes"      => $nodes,
    "fail_ok"    => true,
    "silent"     => true,
    "properties" => {
      "message"  => $message ? {
        String => $message,
        default => sprintf("Disabled using the %s playbook", $facts["choria"]["playbook"])
      }
    }
  )
}
