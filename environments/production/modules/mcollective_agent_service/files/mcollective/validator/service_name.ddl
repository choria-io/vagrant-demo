metadata :name => "service_name",
         :description => "Validates that a string is a service name",
         :author      => "R.I.Pienaar <rip@devco.net>",
         :license     => "Apache-2.0",
         :version     => "4.0.1",
         :url         => "https://github.com/choria-plugins/service-agent",
         :timeout => 1

requires :mcollective => "2.2.1"

usage <<-END_OF_USAGE
Validates if a given string is a valid service name.

In a DDL :
  validation => :service_name

In code :
   MCollective::Validator.validate("puppet", :service_name)

END_OF_USAGE
