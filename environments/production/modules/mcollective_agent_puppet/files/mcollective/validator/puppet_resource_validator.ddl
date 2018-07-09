metadata    :name        => "puppet_resource",
            :description => "Validates the validity of a Puppet resource type and name",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache-2.0",
            :version     => "2.1.0",
            :url         => "https://github.com/choria-plugins/puppet-agent",
            :timeout     => 1

usage <<-EOU
Valid resource names are in the form: resource_type[resource_name].

Resource types has to validate against the regular expression:

   [a-zA-Z0-9_]+

While resource names might be any character.
EOU
