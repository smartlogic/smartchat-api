class UserSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :email, :private_key

  private

  def include_private_key?
    @options[:private_key]
  end
end
