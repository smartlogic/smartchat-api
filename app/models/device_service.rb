module DeviceService
  def create(user, device_attrs, device_klass = Device)
    user.device_destroy
    device_klass.create(device_attrs.merge(:user_id => user.id))
  end
  module_function :create
end
