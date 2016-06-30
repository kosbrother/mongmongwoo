class Api::V3::MmwRegistrationsController < ApiController
  def create
    if params[:email].blank?
      render  status: 400, json: {error: {message: 'email is empty'}}
    elsif User.where.not(password_digest: nil).where.not(password_digest: '').find_by_email(params[:email])
      render  status: 400, json: {error: {message: 'email is already taken'}}
    else
      user = User.find_or_initialize_by(email: params[:email])
      user.password = params[:password]
      user.save
      render status: 200, json: {data: "success"}
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user.nil? || user.password_digest.nil?
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
