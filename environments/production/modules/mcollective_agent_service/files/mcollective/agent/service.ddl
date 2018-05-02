metadata    :name        => "service",
            :description => "Manages Operating System Services",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache-2.0",
            :version     => "4.0.1",
            :url         => "https://github.com/choria-plugins/service-agent",
            :timeout     => 60

requires :mcollective => "2.2.1"

action "status", :description => "Gets the status of a service" do
    display :always

    input :service,
          :prompt      => "Service Name",
          :description => "The service to get the status for",
          :type        => :string,
          :validation  => :service_name,
          :optional    => false,
          :maxlength   => 90

    output :status,
           :description => "The status of the service",
           :display_as  => "Service Status",
           :default     => "unknown"

    summarize do
      aggregate summary(:status)
    end
end

["start", "restart", "stop"].each do |act|
    action act, :description => "#{act.capitalize} a service" do
        display :failed

        input :service,
              :prompt      => "Service Name",
              :description => "The service to #{act}",
              :type        => :string,
              :validation  => :service_name,
              :optional    => false,
              :maxlength   => 90

        output :status,
               :description => "The status of the service after #{act.sub(/p$/, 'pp')}ing",
               :display_as  => "Service Status",
               :default     => "unknown"

        summarize do
          aggregate summary(:status)
        end
    end
end
