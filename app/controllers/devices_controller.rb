class DevicesController < ApplicationController
  def create
    DeviceService.create(current_user, device_params)
    render :json => {}, :status => 201, :serializer => DeviceSerializer
  end

  private

  def device_params
    params.require(:device).permit(:device_id, :device_type)
  end
end
