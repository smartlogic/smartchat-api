require 'tempfile'

class MediaController < ApplicationController
  before_filter :parse_media_tempfile, :only => :create
  before_filter :parse_drawing_tempfile, :only => :create

  after_filter :unlink_tempfiles

  def create
    media_attributes = {
      :friend_ids => params[:media][:friend_ids],
      :file => @media_tempfile
    }

    media_attributes[:drawing] = @drawing_tempfile if @drawing_tempfile

    MediaService.create(current_user, media_attributes)

    render :json => {}, :status => 201, :serializer => MediaSerializer
  end

  private

  def parse_media_tempfile
    ext = params[:media][:file_name].split(".").last
    @media_tempfile = Tempfile.new([params[:media][:file_name], ".#{ext}"])
    File.open(@media_tempfile.path, 'wb') do |file|
      file.write(Base64.decode64(params[:media][:file]))
    end
    @media_tempfile.rewind
  end

  def parse_drawing_tempfile
    if params[:media].has_key?(:drawing) && params[:media][:drawing].present?
      @drawing_tempfile = Tempfile.new(["drawing", ".png"])
      File.open(@drawing_tempfile.path, 'wb') do |file|
        file.write(Base64.decode64(params[:media][:drawing]))
      end
      @drawing_tempfile.rewind
    end
  end

  def unlink_tempfiles
    @media_tempfile.close
    @media_tempfile.unlink

    if @drawing_tempfile
      @drawing_tempfile.close
      @drawing_tempfile.unlink
    end
  end
end
