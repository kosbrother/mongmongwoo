class Api::V3::OauthSessionsController < ApiController
  def create
    errors = []
    ActiveRecord::Base.transaction do
      user = User.find_or_initialize_by(email: params[:email])
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
      render status: 400, json: {error: {message: errors}}
    else
      render status: 200, json: {data: "success"}
    end
  end
end
