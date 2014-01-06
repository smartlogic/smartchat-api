class MediaSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :_links

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
end
