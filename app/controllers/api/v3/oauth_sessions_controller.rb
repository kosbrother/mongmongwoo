class Api::V3::OauthSessionsController < ApiController
  def create
    errors = []
    user = User.find_or_initialize_by(email: params[:email])
    ActiveRecord::Base.transaction do
      user.password = User::FAKE_PASSWORD if  user.password_digest.nil?
      user.user_name = params[:user_name]
      errors << user.errors.messages unless user.save

      login = Login.find_or_initialize_by(provider: params[:provider], uid: params[:uid])
      login.user_id = user.id
      login.user_name = params[:user_name]
      login.gender = params[:gender]
      errors << login.errors.messages unless login.save

      raise ActiveRecord::Rollback if errors.present?
    end
    
    if errors.present?
      Rails.logger.error("error: #{errors}")
      render status: 400, json: {error: {message: errors.to_s}}
    else
      render status: 200, json: {data: user.id}
    end
  end
end