class Admin::MailRecordsController < AdminController
  before_action :require_manager

  def sending_survey_email
    @order = Order.find(params[:order_id])

    if @order.status == "完成取貨" && @order.survey_mail.nil?
      @order.mail_records.create(mail_type: MailRecord.mail_types["satisfaction_survey"])
      OrderMailer.delay.satisfaction_survey(@order)
      flash[:notice] = "滿意度調查問卷已寄出"
    else
      flash[:danger] = "信件無法寄出"
    end

    redirect_to :back
  end
end