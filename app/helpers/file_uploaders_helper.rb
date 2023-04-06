# frozen_string_literal: true

module FileUploadersHelper
  def file_share?(file_uploader)
    file_uploader.share == true ? 'Yes' : 'No'
  end
end
