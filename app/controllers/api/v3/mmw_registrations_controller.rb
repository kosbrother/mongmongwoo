class Api::V3::MmwRegistrationsController < ApiController
  def create
    user = User.new(email: params[:email])
    user.password = params[:password]
    if user.save
      render status: 200, json: {data: "success"}
    else
      Rails.logger.error("error: #{user.errors.messages}")
      render status: 400, json: {error: {message: user.errors.messages}}
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user.nil?
      render status: 400, json: {error: {message: 'can not find user'}}
    elsif  user.authenticate(params[:password])
      render status: 200, json: {data: "success"}
    else
      render status: 400, json: {error: {message: 'password is not correct'}}
    end
  end

  def forget
    user = User.find_by_email(params[:email])
    if user
      user.sent_password_reset
      render status: 200, json: {data: "success"}
    else
      render status: 400, json: {error: {message: 'can not find user'}}
    end
  end
end