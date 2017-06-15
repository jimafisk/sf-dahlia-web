# Job for processing attachment submissions to Salesforce
class ShortFormAttachmentJob < ActiveJob::Base
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |e|
    # catch UploadedFile not being found
  end

  def perform(opts = {})
    file = UploadedFile.find(opts[:file_id])
    # replace :file_id with :file
    opts[:file] = file
    opts.delete(:file_id)
    ShortFormService.attach_file(opts)
    # now that file is saved in SF, remove temp uploads
    file.destroy
  end
end
