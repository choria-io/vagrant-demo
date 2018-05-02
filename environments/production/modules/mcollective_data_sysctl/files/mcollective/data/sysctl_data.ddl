metadata    :name        => "sysctl",
            :description => "Retrieve values for a given sysctl",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache-2.0",
            :version     => "3.0.0",
            :url         => "https://github.com/choria-plugins/sysctl-data",
            :timeout     => 1

requires :mcollective => "2.2.1"

dataquery :description => "Sysctl values" do
    input :query,
          :prompt => "Variable Name",
          :description => "Valid Variable Name",
          :type => :string,
          :validation => /\A^[\w\-\.]+$\z/,
          :maxlength => 120

    output :value,
           :description => "Kernel Parameter Value",
           :display_as => "Value"
end
