class Api::V3::DeviceRegistrationsController < ApiController
  def create
    if DeviceRegistration.find_or_create_by!(registration_id: params[:registration_id])
      render status: 200, json: "Success"
    else
      render status: 400, json: "Fail"
    end
  end
end