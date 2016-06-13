class Api::V3::FbRegistrationsController < ApiController
  def create
    user = User.find_or_initialize_by(email: params[:email])
    unless user.save
      Rails.logger.error("error: #{user.errors.messages}")
      render status: 400, json: {error: {message: user.errors.messages}}
    end

    login = Login.find_or_initialize_by(provider: 'facebook', uid: params[:uid])
    login.user_id = user.id
    login.user_name = params[:user_name]
    login.gender = params[:gender]
    if login.save
      render status: 200, json: {data: "success"}
    else
      Rails.logger.error("error: #{login.errors.messages}")
      render status: 400, json: {error: {message: login.errors.messages}}
    end
  end
end
