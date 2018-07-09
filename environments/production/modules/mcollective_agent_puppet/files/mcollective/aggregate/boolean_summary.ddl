metadata :name        => "boolean_summary",
         :description => "Aggregate function that will transform true/false values into predefined strings.",
         :author      => "R.I.Pienaar <rip@devco.net>",
         :license     => "Apache-2.0",
         :version     => "2.1.0",
         :url         => "https://github.com/choria-plugins/puppet-agent",
         :timeout => 1

usage <<-EOU
An Aggregate plugin that allows you to summarize boolean results and supply custom
titles instead of just 'true' and 'false' the normal summary plugin would provide

   aggregate boolean_summary(:alive, {:true => "Alive", :false => "Dead" })

When displayed this will show:

Summary of Alive:

   Dead = 1
   Alive = 1
EOU
