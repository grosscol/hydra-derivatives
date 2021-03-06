module Hydra::Derivatives
  # This Service is an implementation of the Hydra::Derivatives::PeristOutputFileService
  # It supports basic contained files, which is the behavior associated with Fedora 3 file datastreams that were migrated to Fedora 4
  # and, at the time that this class was authored, corresponds to the behavior of ActiveFedora::Base.attach_file and ActiveFedora::Base.attached_files
  ### Rename this 
  class PersistBasicContainedOutputFileService < PersistOutputFileService

    # This method conforms to the signature of the .call method on Hydra::Derivatives::PeristOutputFileService
    # * Persists the file within the object at destination_name
    #
    # NOTE: Uses basic containment. If you want to use direct containment (ie. with PCDM) you must use a different service (ie. Hydra::Works::AddFileToGenericFile Service)
    #
    # @param [ActiveFedora::Base] object file is be persisted to
    # @param [File] filestream to be added, should respond to :mime_type and :original_name
    #   original_name will get used as the path for a chile resource in fedora, it is not a path to a file on disk.

    def self.call(object, file, destination_path)
      o_name = determine_original_name(file)
      m_type = determine_mime_type(file)
      object.add_file(file, path: destination_path, mime_type: m_type, original_name: o_name)
      object.save
    end

  end
end
