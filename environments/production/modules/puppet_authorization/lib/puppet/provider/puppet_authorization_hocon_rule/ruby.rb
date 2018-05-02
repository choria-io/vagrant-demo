require 'puppet/util/feature'
if Puppet.features.puppet_authorization?
  require 'hocon/config_factory'
  require 'hocon/parser/config_document_factory'
  require 'hocon/config_value_factory'
end

Puppet::Type.type(:puppet_authorization_hocon_rule).provide(:ruby) do

  def exists?
    ret_value = false

    if conf_file.has_value?(setting)
      if resource[:ensure] == :absent
        ret_value = value.any? do |existing|
          Array(@resource[:value]).any? { |v| existing['name'] == v['name'] }
        end
      else
        ret_value = value.any? do |existing|
          Array(@resource[:value]).include?(existing)
        end
      end
    end

    return ret_value
  end

  def create
    conf_file_modified = set_value(resource[:value])
    write_conf(conf_file_modified)
    @conf_file = nil
  end

  def destroy
    conf_file_modified = remove_value(resource[:value])
    write_conf(conf_file_modified)
    @conf_file = nil
  end

  def value
    val = conf_file.has_value?(setting) ?
        conf_object.get_value(setting).unwrapped : []

    # If the current value of the target setting is not an array,
    # present the current value as an empty array so that an
    # element is added to an empty array (as opposed to converting
    # the current value into the first element in an array and
    # adding the value to set as a second element in the array).
    unless val.is_a?(Array)
      val = []
    end
    val
  end

  def value=(new_value)
    conf_file_modified = set_value(new_value)
    write_conf(conf_file_modified)
    @conf_file = nil
  end

  def setting
    'authorization.rules'
  end

  def file_path
    resource[:path]
  end

  private
  def conf_file
    if @conf_file.nil? && (not File.exist?(file_path))
      File.new(file_path, "w")
    end
    @conf_file ||= Hocon::Parser::ConfigDocumentFactory.parse_file(file_path)
  end

  def write_conf(conf)
    File.open(file_path, 'w+') do |fh|
      config_string = conf.render
      fh.puts(config_string)
    end
  end

  def conf_object
    if @conf_file.nil? && (not File.exist?(file_path))
      File.new(file_path, "w")
    end
    Hocon::ConfigFactory.parse_file(file_path)
  end

  def remove_value(value_to_remove)
    # Similar to set_value, only consider the rule name when looking for the
    # rule to remove.
    new_value_tmp = Array(value).reject do |existing|
      Array(value_to_remove).any? { |v| existing['name'] == v['name'] }
    end

    new_value = Hocon::ConfigValueFactory.from_any_ref(new_value_tmp, nil)
    conf_file.set_config_value(setting, new_value)
  end

  def set_value(value_to_set)
    # Prevent duplicate rules by removing existing ones that have the same
    # rule name as the new value_to_set.
    tmp_val = Array(value).reject do |existing|
      value_to_set.any? { |new_val| existing['name'] == new_val['name'] }
    end
    tmp_val.concat(value_to_set)
    tmp_val.sort_by! { |rule| [rule['sort-order'], rule['name']] }

    new_value = Hocon::ConfigValueFactory.from_any_ref(tmp_val, nil)
    conf_file.set_config_value(setting, new_value)
  end
end
