class AllpayController < ActionController::Base
  after_action :update_order_status_if_goods_arrive_store_or_pickup, only: [:create_reply]

  def create
    if PostToAllpayWorker.new.perform(params[:order_id], create_reply_allpay_index_url, status_update_allpay_index_url)
      @message = "已將編號：#{params[:order_id]} 成功傳送到歐付寶"
    else
      @message = "編號：#{params[:order_id]} 傳送到歐付寶 失敗"
    end
  end

  def create_reply
    @order = Order.find(params[:MerchantTradeNo].to_i)
    @order.update_attributes(logistics_status_code: params[:RtnCode].to_i)
    render status: 200, json: { data: "success" }
  end

  private

  def update_order_status_if_goods_arrive_store_or_pickup
    if params[:RtnCode].to_i == Logistics_Status.key("商品配達買家取貨門市")
      @order.update_attributes(status: Order.statuses["已到店"])
    elsif params[:RtnCode].to_i == Logistics_Status.key("買家已到店取貨")
      @order.update_attributes(status: Order.statuses["完成取貨"])
    end
  end
end