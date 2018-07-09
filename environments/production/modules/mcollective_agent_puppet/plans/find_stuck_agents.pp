# Locates agents stuck applying for extended periods of time
#
# When running Puppet in unstable networks one often finds a Puppet Agent stuck
# thinking it's applying a catalog when the applying process have been in the
# process tree for hours or days or weeks and will never die.
#
# This playbook detects these agents and returns a list of affected host, you could
# use this to kill them via some other method of your choice
#
# @param nodes [Choria::Nodes] The nodes to limit the search on, else with the Puppet agent
# @param maxage [Integer] Maximum amount of time between now and last completed run
# @returns [Choria::Nodes] list of stuck nodes
plan mcollective_agent_puppet::find_stuck_agents (
  Choria::Nodes $nodes = [],
  Integer $maxage = 7200,
) {
  if $nodes.empty {
    $_nodes = choria::discover(
      "discovery_method" => "mc",
      "test"             => true,
      "agents"           => ["puppet"]
    )
  } else {
    $_nodes = $nodes
  }

  $stuck = choria::task(
    "nodes"  => $_nodes,
    "action" => "puppet.status",
    "silent" => true,
  ).filter |$status| {
    $status["data"]["applying"] and $status["data"]["since_lastrun"] > $maxage
  }.map |$status| {
    $status.host
  }

  $stuck
}
