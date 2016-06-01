class Admin::MailRecordsController < AdminController
  before_action :require_manager

  def sending_survey_email
    @order = Order.find(params[:order_id])

    if @order.status == "完成取貨" && @order.mail_record.nil?
      @order.mail_record = MailRecord.create(mail_type: 0)
      OrderMailer.delay.satisfaction_survey(@order)
      flash[:notice] = "滿意度調查問卷已寄出"
    else
      flash[:danger] = "信件無法寄出"
    end

    redirect_to admin_user_path(@order.user)
  end
end