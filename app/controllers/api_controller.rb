class ApiController < ActionController::Base
  def android_version
    render json: AndroidVersion.last
  end
end