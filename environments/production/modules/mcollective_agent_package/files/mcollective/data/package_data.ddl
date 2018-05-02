metadata :name        => "package",
         :description => "Checks the status of a package",
         :author      => "R.I.Pienaar <rip@devco.net>",
         :license     => "Apache-2.0",
         :version     => "5.0.1",
         :url         => "https://github.com/choria-plugins/package-agent",
         :timeout     => 3

requires :mcollective => "2.2.1"

usage <<-END_OF_USAGE
Checks the status of a package. This plugin can be used during discovery and everywhere else
the mcollective discovery language is used.

Example Usage:

  During Discovery -  mco rpc rpcutil ping -S "package('puppet').status=3.8.4-1puppetlabs1"
  Action Policy    -  package('puppet').status=3.8.4-1puppetlabs1

END_OF_USAGE

dataquery :description => "package" do
    input :query,
          :prompt => "package Name",
          :description => "Package Name",
          :type => :string,
          :validation => :package_name,
          :maxlength => 50

    output :status,
           :description => "The currently installed version if present",
           :display_as => "Package Status"

    output :installed,
           :description => "true/false",
           :display_as => "Is installed?"
end

