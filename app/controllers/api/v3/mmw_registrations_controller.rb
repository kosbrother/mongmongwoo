class Api::V3::MmwRegistrationsController < ApiController
  def create
    register = User.register(params[:email], params[:password])
    if register[:result]
      render status: 200, json: {data: register[:user].id}
    else
      message = register[:message].join(' ')
      render status: 400, json: {error: {message: message}}
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user.nil? || user.is_mmw_registered == false
      render status: 400, json: {error: {message: t('controller.error.message.no_user')}}
    elsif  user.authenticate(params[:password])
      render status: 200, json: {data: user.id}
    else
      render status: 400, json: {error: {message: t('controller.error.message.wrong_password')}}
    end
  end

  def forget
    user = User.find_by(email: params[:email], is_mmw_registered: true)
    if user
      user.sent_password_reset
      render status: 200, json: {data: "success"}
    else
      render status: 400, json: {error: {message:  t('controller.error.message.no_user')}}
    end
  end
end
