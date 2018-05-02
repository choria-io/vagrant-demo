module MCollective
  module Validator
    class Package_nameValidator
      def self.validate(package_name)
        raise("%s is not a valid package name" % package_name) unless !!(package_name =~ /\A^[a-zA-Z\.\-_\d]+$\z/)
      end
    end
  end
end
