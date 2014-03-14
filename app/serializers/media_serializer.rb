class MediaSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :uuid, :_links, :_embedded, :created_at, :expire_in

  def uuid
    @object.metadata["uuid"]
  end

  def expire_in
    @object.metadata["expire_in"].to_i
  end

  def created_at
    @object.metadata["created_at"]
  end

  def _links
    hash = super

    hash["edit"] = {
      "href" => media_url(uuid),
      "name" => "Mark as viewed"
    }
    hash["smartchat:files"] = [
      {
        "href" => file_url(@object.file_path),
        "name" => "file"
      }
    ]

    if @object.drawing_path
      hash["smartchat:files"] << {
        "href" => file_url(@object.drawing_path),
        "name" => "drawing"
      }
    end

    hash
  end

  def _embedded
    {
      "creator" => {
        "id" => @object.metadata["creator_id"].to_i,
        "username" => @object.metadata["creator_username"]
      }
    }
  end
end
