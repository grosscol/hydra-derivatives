# An abstract class for asyncronous jobs that transcode files using FFMpeg

require 'tmpdir'
require 'open3'

module Hydra
  module Derivatives
    module Ffmpeg
      extend ActiveSupport::Concern

      included do
        extend Open3
      end

      def process
        directives.each do |name, args| 
          raise ArgumentError, "You must provide the :format you want to transcode into. You provided #{args}" unless args[:format]
          # TODO if the source is in the correct format, we could just copy it and skip transcoding.
          encode_datastream(output_datastream_id(name), args[:format], new_mime_type(args[:format]), options_for(args[:format]))
        end
      end

      def encode_datastream(dest_dsid, file_suffix, mime_type, options = '')
        out_file = nil
        output_file = Dir::Tmpname.create(['sufia', ".#{file_suffix}"], Hydra::Derivatives.temp_file_base){}
        source_datastream.to_tempfile do |f|
          self.class.encode(f.path, options, output_file)
        end
        out_file = File.open(output_file, "rb")
        object.add_file_datastream(out_file.read, :dsid=>dest_dsid, :mimeType=>mime_type)
        File.unlink(output_file)
      end

      module ClassMethods

        def encode(path, options, output_file)
          command = "#{Hydra::Derivatives.ffmpeg_path} -y -i \"#{path}\" #{options} #{output_file}"
          stdin, stdout, stderr, wait_thr = popen3(command)
          stdin.close
          out = stdout.read
          stdout.close
          err = stderr.read
          stderr.close
          raise "Unable to execute command \"#{command}\"\n#{err}" unless wait_thr.value.success?
        end
      end

    end
  end
end

