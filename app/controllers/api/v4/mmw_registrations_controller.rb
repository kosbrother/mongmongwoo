class Api::V4::MmwRegistrationsController < ApiController
  def create
    register = User.register(params[:email], params[:password])
    device = DeviceRegistration.find_or_create_by(registration_id: params[:registration_id])

    if register[:result]
      register[:user].devices << device
      render status: 200, json: {data: register[:user].id}
    else
      message = register[:message].join(' ')
      render status: 400, json: message
    end
  end
end
