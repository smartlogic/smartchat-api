require 'tempfile'

class MediaController < ApplicationController
  def create
    ext = params[:media][:file_name].split(".").last
    tempfile = Tempfile.new([params[:media][:file_name], ".#{ext}"])
    File.open(tempfile.path, 'wb') do |file|
      file.write(Base64.decode64(params[:media][:file]))
    end
    tempfile.rewind

    MediaService.create(current_user, {
      :friend_ids => params[:media][:friend_ids],
      :file => tempfile
    })

    render :json => {}, :status => 201, :serializer => MediaSerializer
  ensure
    tempfile.close
    tempfile.unlink
  end
end
