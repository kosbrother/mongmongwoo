class Api::V4::MmwRegistrationsController < Api::SessionsController
  before_action  :reguire_registration_id

  def create
    register = User.register(params[:email], params[:password])

    if register[:result]
      device = DeviceRegistration.find_or_create_by(registration_id: params[:registration_id])
      register[:user].devices << device
      render status: 200, json: {data: register[:user].id}
    else
      message = register[:message].join(' ')
      render status: 400, json: message
    end
  end

  def login
    user = User.find_by(email: params[:email])
    device = DeviceRegistration.find_or_create_by(registration_id: params[:registration_id])

    if user.nil? || user.is_mmw_registered == false
      render status: 400, json: t('controller.error.message.no_user')
    elsif  user.authenticate(params[:password])
      user.devices << device
      render status: 200, json: {data: user.id}
    else
      render status: 400, json: t('controller.error.message.wrong_password')
    end
  end
end