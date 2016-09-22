class Pay2goController < ActionController::Base
  def notify
    order = Order.find(params[:order_id])

    if params["Status"] == "SUCCESS"
      order.update_attribute(:is_paid, true)
      redirect_to success_path
    else
      render text: "信用卡交易失敗"
    end
  end
end