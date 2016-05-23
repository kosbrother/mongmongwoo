class AllpayController < ActionController::Base
  def create
    if PostToAllpayWorker.new.perform(params[:order_id], create_reply_allpay_index_url, status_update_allpay_index_url)
      @message = "已將編號：#{params[:order_id]} 成功傳送到歐付寶"
    else
      @message = "編號：#{params[:order_id]} 傳送到歐付寶 失敗"
    end
  end

  def status_update
  end

  def create_reply
    order = Order.find(params[:MerchantTradeNo].to_i)
    order.update_attributes(logistics_status_code: params[:RtnCode].to_i)
    @message = "已將訂單：#{order.id}的物流狀態更新為：#{Logistics_Status[order.logistics_status_code]}"
  end
end