class Api::V1::UsersController < ApiController
  def create
    params[:email] = User.fake_mail(params[:uid]) if params[:email].blank?
    user = User.find_or_initialize_by(email: params[:email])
    user.password = User::FAKE_PASSWORD if  user.password_digest.nil?
    user.user_name = params[:user_name]
    user.gender = params[:gender]
    if user.save
      render json: "Successfully Create"
    else
      Rails.logger.error("error: #{user.errors.messages}")
      render json: "Error"
    end
  end
end
