class MediaCreationSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attribute :uuid

  def uuid
    @object[:uuid]
  end
end
