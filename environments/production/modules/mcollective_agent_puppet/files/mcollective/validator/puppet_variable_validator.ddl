metadata    :name        => "puppet_variable",
            :description => "Validates that a variable name is a valid Puppet name",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache-2.0",
            :version     => "2.1.0",
            :url         => "https://github.com/choria-plugins/puppet-agent",
            :timeout     => 1

usage <<-EOU
Puppet variable naming rules applies to variables, classes and tags.

Valid variable names that are longer than 1 character would need to match:

    /\A[a-zA-Z]\Z/

While multi character variable names has to match:

    /\A[a-zA-Z0-9_]+\Z/

For full documentation see the Puppet documentation at http://docs.puppetlabs.com
EOU
