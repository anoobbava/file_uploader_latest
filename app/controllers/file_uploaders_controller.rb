# frozen_string_literal: true

#
# Class FileUploadersController provides the option to handle the files uploaded and its functionalities
#
# @author Anoob Bava <anoob.bava@gmail.com>
#
class FileUploadersController < ApplicationController
  before_action :set_file_uploader, only: %i[show edit update destroy]
  skip_before_action :authenticate_user!, only: [:download]

  def index
    @file_uploaders = FileUploader.where(user_id: current_user.id)
  end

  def show; end

  def new
    @file_uploader = FileUploader.new
  end

  def edit; end

  def create
    @file_uploader = FileUploader.new(file_uploader_params.merge!(user_id: current_user.id,
                                                                  short_url: ShortUrlService.generate_short_url))
    respond_to do |format|
      if @file_uploader.save
        ShortUrlService.generate_short_url
        format.html { redirect_to file_uploader_url(@file_uploader), notice: 'File uploader was successfully created.' }
        format.json { render :show, status: :created, location: @file_uploader }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @file_uploader.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @file_uploader.update(file_uploader_params.merge!(user_id: current_user.id,
                                                           short_url: ShortUrlService.generate_short_url))
        format.html { redirect_to file_uploader_url(@file_uploader), notice: 'File uploader was successfully updated.' }
        format.json { render :show, status: :ok, location: @file_uploader }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @file_uploader.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @file_uploader.file_data.purge
    @file_uploader.destroy

    respond_to do |format|
      format.html { redirect_to file_uploaders_url, notice: 'File uploader was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Download the file from tiny url
  def download
    file_uploader = FileUploader.find_by(short_url: params[:short_url])
    if file_uploader.share?
      redirect_to rails_blob_path(file_uploader.file_data, disposition: 'attachment')
    else
      Rails.logger.info 'not able to share this file'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_file_uploader
    @file_uploader = FileUploader.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def file_uploader_params
    params.require(:file_uploader).permit(:title, :description, :user_id, :file_data, :short_url, :share)
  end
end
