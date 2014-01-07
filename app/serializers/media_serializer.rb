class MediaSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :_links, :_embedded, :created_at

  def created_at
    @object.metadata["created_at"]
  end

  def _links
    hash = super

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
        "email" => @object.metadata["creator_email"]
      }
    }
  end
end
