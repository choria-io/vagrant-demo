metadata    :name        => "package",
            :description => "Manage Operating System Packages",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache-2.0",
            :version     => "5.0.1",
            :url         => "https://github.com/choria-plugins/package-agent",
            :timeout     => 180

requires :mcollective => "2.2.1"

["install", "update", "uninstall", "purge"].each do |act|
    action act, :description => "#{act.capitalize} a package" do
        input :package,
              :prompt      => "Package Name",
              :description => "Package to #{act}",
              :type        => :string,
              :validation  => :shellsafe,
              :optional    => false,
              :maxlength   => 90

  if act == 'install'
        input :version,
              :prompt      => "Package version",
              :description => "Version of package to #{act}",
              :type        => :string,
              :validation  => :shellsafe,
              :optional    => true,
              :maxlength   => 90
  end

        output :output,
               :description => "Output from the package manager",
               :display_as  => "Output"

        output :epoch,
               :description => "Package epoch number",
               :display_as  => "Epoch"

        output :arch,
               :description => "Package architecture",
               :display_as  => "Arch"

        output :ensure,
               :description => "Full package version",
               :display_as  => "Ensure"

        output :version,
               :description => "Version number",
               :display_as  => "Version"

        output :provider,
               :description => "Provider used to retrieve information",
               :display_as => "Provider"

        output :name,
               :description => "Package name",
               :display_as => "Name"

        output :release,
               :description => "Package release number",
               :display_as => "Release"

        summarize do
          aggregate summary(:ensure)
        end
    end
end

action "status", :description => "Get the status of a package" do
    display :always

    input :package,
          :prompt      => "Package Name",
          :description => "Package to retrieve the status of",
          :type        => :string,
          :validation  => :shellsafe,
          :optional    => false,
          :maxlength   => 90

    output :output,
           :description => "Output from the package manager",
           :display_as  => "Output"

    output :epoch,
           :description => "Package epoch number",
           :display_as  => "Epoch"

    output :arch,
           :description => "Package architecture",
           :display_as  => "Arch"

    output :ensure,
           :description => "Full package version",
           :display_as  => "Ensure"

    output :version,
           :description => "Version number",
           :display_as  => "Version"

    output :provider,
           :description => "Provider used to retrieve information",
           :display_as => "Provider"

    output :name,
           :description => "Package name",
           :display_as => "Name"

    output :release,
           :description => "Package release number",
           :display_as => "Release"

    summarize do
      aggregate summary(:ensure)
      aggregate summary(:arch)
    end
end

action "count", :description => "Get number of packages installed" do
    output :output,
           :description => "Count of packages installed",
           :display_as  => "Count"

    output :exitcode,
           :description => "The exitcode from the rpm/dpkg command",
           :display_as => "Exit Code"
    summarize do
      aggregate summary(:output)
    end
end

action "md5", :description => "Get md5 digest of list of packages installed" do
    output :output,
           :description => "md5 of list of packages installed",
           :display_as  => "MD5"

    output :exitcode,
           :description => "The exitcode from the rpm/dpkg command",
           :display_as => "Exit Code"
    summarize do
      aggregate summary(:output)
    end
end

action "yum_clean", :description => "Clean the YUM cache" do
    input :mode,
          :prompt      => "Yum clean mode",
          :description => "One of the various supported clean modes",
          :type        => :list,
          :optional    => true,
          :list        => ["all", "headers", "packages", "metadata", "dbcache", "plugins", "expire-cache"]

    output :output,
           :description => "Output from YUM",
           :display_as  => "Output"

    output :exitcode,
           :description => "The exitcode from the yum command",
           :display_as => "Exit Code"
end

action "apt_update", :description => "Update the apt cache" do
    output :output,
           :description => "Output from apt-get",
           :display_as  => "Output"

    output :exitcode,
           :description => "The exitcode from the apt-get command",
           :display_as => "Exit Code"
end

action "yum_checkupdates", :description => "Check for YUM updates" do
    display :always

    output :output,
           :description => "Output from YUM",
           :display_as  => "Output"

    output :outdated_packages,
           :description => "Outdated packages",
           :display_as  => "Outdated Packages"

    output :exitcode,
           :description => "The exitcode from the yum command",
           :display_as => "Exit Code"
end

action "apt_checkupdates", :description => "Check for APT updates" do
    display :always

    output :output,
           :description => "Output from APT",
           :display_as  => "Output"

    output :outdated_packages,
           :description => "Outdated packages",
           :display_as  => "Outdated Packages"

    output :exitcode,
           :description => "The exitcode from the apt command",
           :display_as => "Exit Code"
end

action "checkupdates", :description => "Check for updates" do
    display :always

    output :package_manager,
           :description => "The detected package manager",
           :display_as  => "Package Manager"

    output :output,
           :description => "Output from Package Manager",
           :display_as  => "Output"

    output :outdated_packages,
           :description => "Outdated packages",
           :display_as  => "Outdated Packages"

    output :exitcode,
           :description => "The exitcode from the package manager command",
           :display_as => "Exit Code"
end
