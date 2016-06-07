class Api::V3::DeviceRegistrationsController < ApiController
  def create
    DeviceRegistration.find_or_create_by!(registration_id: params[:registration_id])
    render status: 200, json: {data: "success"}
  end
end