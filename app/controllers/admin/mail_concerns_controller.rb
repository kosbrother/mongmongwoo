class Admin::MailConcernsController < AdminController
  before_action :require_manager

  def sending_survey_email
    find_mail_concern_of_order

    if @order.status == "完成取貨" && @mail_concern.is_sent_change.nil? && @mail_concern.sent_email_at.nil?
      @mail_concern.update_attributes(is_sent: true, sent_email_at: Time.now)
      flash[:notice] = "滿意度調查問卷已寄出"
    else
      flash[:danger] = "信件無法寄出"
    end
    redirect_to admin_user_path(@order.user)
  end

  private

  def find_mail_concern_of_order
    @order = Order.find(params[:order_id])
    @mail_concern = @order.mail_concern
  end
end