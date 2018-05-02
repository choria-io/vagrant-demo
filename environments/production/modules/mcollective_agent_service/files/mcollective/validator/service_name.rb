module MCollective
  module Validator
    class Service_nameValidator
      def self.validate(service_name)
        raise("%s is not a valid service name" % service_name) unless !!(service_name =~ /\A^[a-zA-Z\.\-_\d:@]+$\z/)
      end
    end
  end
end
