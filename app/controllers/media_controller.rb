require 'tempfile'

class MediaController < ApplicationController
  before_filter :parse_media_tempfile, :only => :create
  before_filter :parse_drawing_tempfile, :only => :create

  def index
    render({
      :json => current_user.media.published,
      :status => 200,
      :serializer => MediaIndexSerializer
    })
  end

  def create
    friend_ids = params[:media][:friend_ids]
    file_path = @media_tempfile.path
    drawing_path = @drawing_tempfile.path if @drawing_tempfile

    MediaService.create(current_user, friend_ids, file_path, drawing_path)

    render :json => {}, :status => 202, :serializer => MediaCreationSerializer
  end

  private

  def parse_media_tempfile
    ext = params[:media][:file_name].split(".").last
    @media_tempfile = Tempfile.new([params[:media][:file_name], ".#{ext}"])
    File.open(@media_tempfile.path, 'wb') do |file|
      file.write(Base64.decode64(params[:media][:file]))
    end
  end

  def parse_drawing_tempfile
    if params[:media].has_key?(:drawing) && params[:media][:drawing].present?
      @drawing_tempfile = Tempfile.new(["drawing", ".png"])
      File.open(@drawing_tempfile.path, 'wb') do |file|
        file.write(Base64.decode64(params[:media][:drawing]))
      end
    end
  end
end
