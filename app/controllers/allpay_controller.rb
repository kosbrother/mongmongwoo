class AllpayController < ActionController::Base
  def create_from_processing
    fail_messages = []
    Order.status(Order.statuses["處理中"]).nil_logistics_code.each do |order|
      results = PostToAllpayWorker.new.perform(order.id, create_reply_allpay_index_url, status_update_allpay_index_url)

      if results[0] == false
        id =  order.id
        error = results[1].to_s.force_encoding("UTF-8").delete!("0|")
        message = "編號：#{id} 傳送到歐付寶失敗\n錯誤訊息：#{error}\n"
        fail_messages << message
      end
    end

    if fail_messages.present?
      @fail_messages = fail_messages.join("\n")
    else
      @success_message = "全部處理中訂單已成功傳送到歐付寶"
    end
  end

  def create_from_order_changed
    fail_messages = []
    order = Order.find(params[:order_id])
    results = PostToAllpayWorker.new.perform(order.id, create_reply_allpay_index_url, status_update_allpay_index_url)

    if results[0] == false
      id =  order.id
      error = results[1].to_s.force_encoding("UTF-8").delete!("0|")
      message = "編號：#{id} 傳送到歐付寶失敗\n錯誤訊息：#{error}\n"
      fail_messages << message
    end

    if fail_messages.present?
      @fail_messages = fail_messages.join("\n")
    else
      @success_message = "變更的訂單已成功傳送到歐付寶"
    end

    render "create_from_processing"
  end

  def create_reply
    order = Order.find(params[:MerchantTradeNo].to_i)
    order.update_attributes(logistics_status_code: params[:RtnCode].to_i)
    order.update_attributes(allpay_transfer_id: params[:AllPayLogisticsID].to_i)
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
end