metadata :name        => "package_name",
         :description => "Validates that a string is a package name",
         :author      => "R.I.Pienaar <rip@devco.net>",
         :license     => "Apache-2.0",
         :version     => "5.0.1",
         :url         => "https://github.com/choria-plugins/package-agent",
         :timeout     => 1

requires :mcollective => "2.2.1"

usage <<-END_OF_USAGE
Validates if a given string is a valid package name.

In a DDL :
  validation => :package_name

In code :
   MCollective::Validator.validate("puppet", :package_name)

END_OF_USAGE
