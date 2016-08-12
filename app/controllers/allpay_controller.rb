class AllpayController < ActionController::Base
  def create_from_processing
    fail_ids = []
    Order.status(Order.statuses["處理中"]).nil_logistics_code.each do |order|
      fail_ids << order.id unless PostToAllpayWorker.new.perform(order.id, create_reply_allpay_index_url, status_update_allpay_index_url)
    end
    if fail_ids.present?
      @message = "編號：#{fail_ids.join(',')} 傳送到歐付寶 失敗"
    else
      @message = "全部處理中訂單已成功傳送到歐付寶"
    end
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