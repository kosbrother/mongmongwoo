class Api::SessionsController < ApiController
  def reguire_registration_id
    render status: 400, json: t('controller.error.message.no_regitration_id') if params[:registration_id].blank?
  end
end