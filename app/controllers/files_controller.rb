class FilesController < ApplicationController
  def show
    data = AppContainer.media_store.read_once(params[:file_path])

    if data
      send_data data
    else
      head 404
    end
  end
end
