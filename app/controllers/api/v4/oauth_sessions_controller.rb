class Api::V4::OauthSessionsController < Api::SessionsController
  before_action  :reguire_registration_id
  
  def create
    errors = []
    user = User.find_or_initialize_by(email: params[:email])
    ActiveRecord::Base.transaction do
      user.password = User::FAKE_PASSWORD if user.password_digest.nil?
      user.user_name = params[:user_name]
      errors << user.errors.messages.values.flatten unless user.save
      device = DeviceRegistration.find_or_create_by(registration_id: params[:registration_id])
      user.devices << device

      login = Login.find_or_initialize_by(provider: params[:provider], uid: params[:uid])
      login.user_id = user.id
      login.user_name = params[:user_name]
      login.gender = params[:gender]
      errors << login.errors.messages.values.flatten unless login.save

      raise ActiveRecord::Rollback if errors.present?
    end

    if errors.present?
      Rails.logger.error("error: #{errors}")
      render status: 400, json: errors.join(', ')
    else
      render status: 200, json: {data: user.id}
    end
  end
end