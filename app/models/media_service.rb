module MediaService
  def create(user, params, media_klass = Media)
    media_klass.create(params.except(:friend_ids).merge(:user_id => user.id))
  end
  module_function :create
end
