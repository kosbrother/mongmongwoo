class Pay2goController < ActionController::Base
  def return
    result = ActiveSupport::JSON.decode(params["Result"])
    order_id = result["MerchantOrderNo"]
    order = Order.find(order_id)

    if params["Status"] == "SUCCESS"
      order.update_attribute(:is_paid, true)
      redirect_to success_path
    else
      render text: "信用卡交易失敗，請聯絡客服人員"
    end
  end

  def notify
    if params["Status"] == "SUCCESS"
      render status: 200, json: {data: "success"}
    else
      Rails.logger.error(params["Status"] + ":" + params["Message "])
      render status: 400, json: {error: "信用卡交易失敗"}
    end
  end
end