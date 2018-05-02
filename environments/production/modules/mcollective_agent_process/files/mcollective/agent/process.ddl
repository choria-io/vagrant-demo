metadata    :name        => "process",
            :description => "Manages Operating System Processes",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache-2.0",
            :version     => "4.0.2",
            :url         => "https://github.com/choria-plugins/process-agent",
            :timeout     => 10

requires :mcollective => '2.2.1'

action "list", :description => "List Processes" do
    input :pattern,
          :prompt      => "Pattern to match",
          :description => "List only processes matching this patten",
          :type        => :string,
          :validation  => :shellsafe,
          :optional    => true,
          :maxlength    => 50

    input :just_zombies,
          :prompt      => "Zombies Only",
          :description => "Restrict the process list to Zombie Processes only",
          :type        => :boolean,
          :optional    => true

    input :user,
          :prompt      => "User's processes only",
          :description => "Restrict the process list to processes executed as defined user",
          :type        => :string,
          :validation  => :shellsafe,
          :optional    => true,
          :maxlength    => 50

    output :pslist,
           :description => "Process List",
           :display_as => "The Process List"

    summarize do
      aggregate process_summary(:pslist)
    end
end
