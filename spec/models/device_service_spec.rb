require 'spec_helper'

describe DeviceService do
  let(:device_attributes) { {
    :device_id => "123",
    :device_type => "android"
  } }

  it "should create a device" do
    user = double(:user, :id => 1)

    device_klass_double = double(:Device)
    expect(device_klass_double).to receive(:create).with(device_attributes.merge(:user_id => user.id))

    DeviceService.create(user, device_attributes, device_klass_double)
  end
end
