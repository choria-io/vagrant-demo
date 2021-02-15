# frozen_string_literal: true

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    run_shell('puppet resource package hocon ensure=latest provider=puppet_gem')
  end
end

def setup_test_directory
  basedir = case os[:family]
            when 'windows'
              'c:/hocon_test'
            else
              '/tmp/hocon_test'
            end
  pp = <<-MANIFEST
    file { '#{basedir}':
      ensure  => directory,
      force   => true,
      purge   => true,
      recurse => true,
    }
    file { '#{basedir}/file':
      content => "file exists\n",
      force   => true,
    }
  MANIFEST
  apply_manifest(pp)
  basedir
end
