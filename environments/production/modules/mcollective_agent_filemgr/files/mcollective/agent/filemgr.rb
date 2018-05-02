require 'fileutils'
require 'digest/md5'

module MCollective
  module Agent
    # A basic file management agent, you can touch, remove or inspec files.
    #
    # A common use case for this plugin is to test your mcollective setup
    # as such if you just call the touch/info/remove actions with no arguments
    # it will default to the file /var/run/mcollective.plugin.filemgr.touch
    # or whatever is specified in the plugin.filemgr.touch_file setting
    class Filemgr<RPC::Agent
      action "touch" do
        touch
      end

      # Basic file removal action
      action "remove" do
        remove
      end

      # Basic status of a file
      action "status" do
        status
      end

      def get_filename
        request[:file] || config.pluginconf["filemgr.touch_file"] || "/var/run/mcollective.plugin.filemgr.touch"
      end

      def status
        file = get_filename
        reply[:name] = file
        reply[:output] = "not present"
        reply[:type] = "unknown"
        reply[:mode] = "0000"
        reply[:present] = 0
        reply[:size] = 0
        reply[:mtime] = 0
        reply[:ctime] = 0
        reply[:atime] = 0
        reply[:mtime_seconds] = 0
        reply[:ctime_seconds] = 0
        reply[:atime_seconds] = 0
        reply[:md5] = 0
        reply[:uid] = 0
        reply[:gid] = 0

        if File.exists?(file)
          Log.debug("Asked for status of '#{file}' - it is present")
          reply[:output] = "present"
          reply[:present] = 1

          if File.symlink?(file)
            stat = File.lstat(file)
          else
            stat = File.stat(file)
          end

          [:size, :mtime, :ctime, :atime, :uid, :gid].each do |item|
            reply[item] = stat.send(item)
          end

          [:mtime, :ctime, :atime].each do |item|
            reply["#{item}_seconds".to_sym] = stat.send(item).to_i
          end

          reply[:mode] = "%o" % [stat.mode]
          reply[:md5] = Digest::MD5.hexdigest(File.read(file)) if stat.file?

          reply[:type] = "directory" if stat.directory?
          reply[:type] = "file" if stat.file?
          reply[:type] = "symlink" if stat.symlink?
          reply[:type] = "socket" if stat.socket?
          reply[:type] = "chardev" if stat.chardev?
          reply[:type] = "blockdev" if stat.blockdev?

          if File.directory?(file) && request[:dirlist]
            dir_filelist = Dir.entries(file)
            # remove superfluous . and .. entries
            dir_filelist -= [".",".."]
            reply[:dir_listing] = dir_filelist
          end

        else
          Log.debug("Asked for status of '#{file}' - it is not present")
          reply.fail! "#{file} does not exist"
        end
      end

      def remove
        file = get_filename

        if File.exists?(file) || File.symlink?(file)
          begin
            FileUtils.rm(file)
            Log.debug("Removed file '#{file}'")
            reply.statusmsg = "OK"
          rescue Exception => e
            Log.warn("Could not remove file '#{file}': #{e.class}: #{e}")
            reply.fail! "Could not remove file '#{file}': #{e.class}: #{e}"
          end
        else
          Log.debug("Asked to remove file '#{file}', but it does not exist")
          reply.fail! "Could not remove file '#{file}' - it is not present"
        end
      end

      def touch
        file = get_filename

        begin
          FileUtils.touch(file)
          Log.debug("Touched file '#{file}'")
        rescue Exception => e
          Log.warn("Could not touch file '#{file}': #{e.class}: #{e}")
          reply.fail! "Could not touch file '#{file}': #{e.class}: #{e}"
        end
      end
    end
  end
end

