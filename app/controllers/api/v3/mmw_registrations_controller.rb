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
end
