class Pay2goController < ActionController::Base
  def return
    result = JSON.parse(params["Result"])
    order_id = result["MerchantOrderNo"]
    order = Order.find(order_id)
    redirect_to success_path(order_id: order.id)
  end

  def notify
    data = JSON.parse(params["JSONData"])

    if data["Status"] == "SUCCESS"
      result = JSON.parse(data["Result"])
      order_id = result["MerchantOrderNo"]
      order = Order.find(order_id)
      order.update_attribute(:is_paid, true)
      OrderMailer.delay.notify_order_placed(order)
      render status: 200, json: {data: "success"}
    else
      Rails.logger.error(data["Status"] + " : " + data["Message"])
      render status: 400, json: {error: "信用卡交易失敗"}
    end
  end
end