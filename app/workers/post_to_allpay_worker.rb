class PostToAllpayWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3
  
  def perform(order_id, create_reply_url, status_update_url)
    order = Order.find(order_id)
    order_id = (order.status == "訂單變更" ? order.allpay_id : order.id)
    @params = { 
      "MerchantTradeNo"=> order_id,
      "ServerReplyURL"=> create_reply_url,
      "LogisticsC2CReplyURL" => status_update_url,
      "GoodsAmount"=> order.total,
      "CollectionAmount"=> order.total,
      "GoodsName"=> "萌萌屋訂單:#{order_id}",
      "SenderName"=> "柯力中",
      "SenderPhone"=>'0912585506',
      "SenderCellPhone" => "0912585506",
      "ReceiverName"=> order.info.ship_name,
      "ReceiverPhone" => order.info.ship_phone,
      "ReceiverCellPhone"=> order.info.ship_phone,
      "ReceiverStoreID"=> order.info.store.store_code
    }
    allpay = AllpayGoodsService.new(@params)
    result = allpay.create_order
    if result[0]
      /AllPayLogisticsID=(\d*)/ =~ result[1]
      order.update_attributes(allpay_transfer_id: $1.to_i)
    end
    result
  end

end