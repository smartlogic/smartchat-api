class FilesController < ApplicationController
  def show
    data = AppContainer.media_store.read_once(file_path)

    if data
      send_data data
    else
      head 404
    end
  end

  private

  def file_path
    if params[:format]
      "#{params[:file_path]}.#{params[:format]}"
    else
      params[:file_path]
    end
  end
end
