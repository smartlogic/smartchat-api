class MediaSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :encrypted_aes_key, :encrypted_aes_iv, :drawing_encrypted_aes_key,
    :drawing_encrypted_aes_iv, :_links

  def include_encrypted_aes_key?
    @object.published?
  end

  def include_encrypted_aes_iv?
    @object.published?
  end

  def include_drawing_encrypted_aes_key?
    @object.published?
  end

  def include_drawing_encrypted_aes_iv?
    @object.published?
  end

  def _links
    hash = super

    hash["smartchat:files"] = [
      {
        "href" => file_url(@object[:file]),
        "name" => "file"
      }
    ]

    if @object.drawing?
      hash["smartchat:files"] << {
        "href" => file_url(@object[:drawing]),
        "name" => "drawing"
      }
    end

    hash
  end
end
