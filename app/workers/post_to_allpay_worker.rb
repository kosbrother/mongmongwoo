class PostToAllpayWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3
  
  def perform(order_id, create_reply_url, status_update_url)
    order = Order.find(order_id)
    @params = { 
      "MerchantTradeNo"=> order.id,
      "ServerReplyURL"=> create_reply_url,
      "LogisticsC2CReplyURL" => status_update_url,
      "GoodsAmount"=> order.total,
      "CollectionAmount"=> order.total,
      "GoodsName"=> "萌萌屋訂單:#{order.id}",
      "SenderName"=> "柯力中",
      "SenderPhone"=>'0912585506',
      "SenderCellPhone" => "0912585506",
      "ReceiverName"=> order.info.ship_name,
      "ReceiverPhone" => order.info.ship_phone,
      "ReceiverCellPhone"=> order.info.ship_phone,
      "ReceiverStoreID"=> order.info.store.store_code
    }
    allpay = AllpayGoodsService.new(@params)
    allpay.create_order
  end

end