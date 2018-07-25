# Discovers nodes running Puppet
#
# If the nodes list is given and not empty that node
# list will be used else a discovery will be done using
# the users default discovery method
#
# Should no nodes be found an error will be raised
#
# @param nodes [Choria::Nodes] only discovers when this is empty
# @return [Choria::Nodes]
plan mcollective_agent_puppet::discover (
  Choria::Nodes $nodes = []
) {
  if !$nodes.empty {
    return $nodes
  }

  choria::discover(
    "test"     => true,
    "at_least" => 1,
    "agents"   => ["puppet"]
  )
}
