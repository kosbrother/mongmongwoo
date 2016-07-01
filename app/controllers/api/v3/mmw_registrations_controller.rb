class Api::V3::MmwRegistrationsController < ApiController
  def create
    if User.where.not(password_digest: nil).find_by(email: params[:email])
      render  status: 400, json: {error: {message: 'email is already taken'}}
    else
      user = User.find_or_initialize_by(email: params[:email])
      user.password = params[:password]
      if user.save
        render status: 200, json: {data: "success"}
      else
        render status: 400, json: {error: {message: 'email or password is not correct'}}
      end
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
