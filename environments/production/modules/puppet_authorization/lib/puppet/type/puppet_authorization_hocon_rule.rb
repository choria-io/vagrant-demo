Puppet::Type.newtype(:puppet_authorization_hocon_rule) do

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:path) do
    desc 'The file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  newproperty(:value, :array_matching => :all) do
    desc 'The value of the setting to be defined.'

    validate do |val|
      unless val.is_a?(Hash)
        raise "Value must be a hash but was #{value.class}"
      end
      validate_acl(val)
    end

    def validate_acl(val)
      ["allow", "deny"].each do |rule|
        if val.has_key?(rule)
          if val[rule].is_a?(Hash)
            validate_acl_hash(val[rule], rule)
          elsif val[rule].is_a?(Array)
            hashes = val[rule].select {|cur_rule| cur_rule.is_a?(Hash) }
            hashes.each {|cur_rule| validate_acl_hash(cur_rule, rule) }
          end
        end
      end
    end

    def validate_acl_hash(val, rule)
      allowed_keys = ["certname", "extensions"]
      unknown_keys = val.reject { |k, _| allowed_keys.include?(k) }
      unless unknown_keys.empty?
        raise "Only one of 'certname' and 'extensions' are allowed keys in a #{rule} hash. Found '#{unknown_keys.keys.join(', ')}'."
      end
      unless val.length == 1
        raise "Only one of 'certname' and 'extensions' are allowed keys in a #{rule} hash."
      end
    end

    def insync?(is)
      # make sure all passed values are in the file
      Array(@resource[:value]).each do |v|
        if not provider.value.flatten.include?(v)
          return false
        end
      end
      return true
    end

    def change_to_s(current, new)
      real_new = []
      real_new << current
      real_new << new
      real_new.flatten!
      real_new.uniq!
      "value changed [#{Array(current).flatten.join(", ")}] to [#{real_new.join(", ")}]"
    end
  end

  validate do
    message = ""
    if self.original_parameters[:path].nil?
      message += "path is a required parameter. "
    end
    if self.original_parameters[:value].nil? && self[:ensure] != :absent
      message += "value is a required parameter unless ensuring a setting is absent."
    end
    if message != ""
      raise(Puppet::Error, message)
    end
  end
end
