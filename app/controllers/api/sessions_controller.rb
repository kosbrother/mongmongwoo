class Api::SessionsController < ApiController
  def reguire_registration_id
    if params[:registration_id].blank?
      Rails.logger.info(t('controller.error.message.no_regitration_id'))
      Rails.logger.info(params.inspect)
      render status: 400, json: t('controller.error.message.no_regitration_id')
    end
  end
end