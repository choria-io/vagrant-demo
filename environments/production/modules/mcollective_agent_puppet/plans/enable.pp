# Enables Puppet on the provided nodes
#
# @param nodes [Choria::Nodes] The nodes to enable
# @returns [Choria::TaskResults]
plan mcollective_agent_puppet::enable (
  Choria::Nodes $nodes,
) {
  choria::task(
    "action"     => "puppet.enable",
    "nodes"      => $nodes,
    "fail_ok"    => true,
    "silent"     => true
  )
}
