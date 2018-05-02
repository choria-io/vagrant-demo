module MCollective
  module Util
    class Processagent
      def self.bytes_to_human(number)
        return "0 B" if number < 1

        units = ["B", "KB", "MB", "GB", "TB"]
        e = (Math.log(number) / Math.log(1024)).floor
        # Cap at TB
        e = 4 if e > 4
        s = "%.3f " % (number.to_f / 1024**e)
        s.sub(/\.?0*$/, units[e])
      end
    end
  end
end
