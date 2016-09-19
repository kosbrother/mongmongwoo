class AllpayController < ActionController::Base
  def create_from_processing
    error_messages = []
    Order.status(Order.statuses["處理中"]).nil_logistics_code.each do |order|
      error_message = post_order_to_allpay_result(order)
      error_messages << error_message if error_message.present?
    end

    if error_messages.present?
      @error_message = error_messages.join("\n")
    else
      @success_message = "全部處理中訂單已成功傳送到歐付寶"
    end
  end

  def post_order_to_allpay
    order = Order.find(params[:order_id])
    error_message = post_order_to_allpay_result(order)

    if error_message.present?
      @error_message = error_message
    else
      @success_message = "變更的訂單已成功傳送到歐付寶"
    end

    render "create_from_processing"
  end

  def create_reply
    order = Order.find_by_id(params[:MerchantTradeNo].to_i)
    order = Order.find_by(allpay_transfer_id: params[:AllPayLogisticsID].to_i) if order.nil?
    order.update_attributes(logistics_status_code: params[:RtnCode].to_i)
    render status: 200, json: { data: "success" }
  end

  def barcode
    order = Order.find(params[:order_id])
    @params = { 
      "AllPayLogisticsID"=> order.allpay_transfer_id
    }
    allpay = AllpayGoodsService.new(@params)
    barcode_html = allpay.create_barcode

    render :text => barcode_html
  end

  private

  def post_order_to_allpay_result(order)
    error_message = ""
    result = PostToAllpayWorker.new.perform(order.id, create_reply_allpay_index_url, status_update_allpay_index_url)

    if result[0] == false
      id =  order.id
      error = result[1].to_s.force_encoding("UTF-8").delete!("0|")
      error_message = "編號：#{id} 傳送到歐付寶失敗\n錯誤訊息：#{error}\n"
    end

    error_message
  end
end