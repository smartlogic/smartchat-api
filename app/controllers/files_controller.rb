class FilesController < ApplicationController
  def show
    data, encrypted_aes_key, encrypted_aes_iv = AppContainer.media_store.read_once(params[:file_path])

    if data
      headers["Encrypted-Aes-Key"] = encrypted_aes_key
      headers["Encrypted-Aes-Iv"] = encrypted_aes_iv
      send_data data
    else
      head 404
    end
  end
end
