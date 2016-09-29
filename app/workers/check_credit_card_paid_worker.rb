class CheckCreditCardPaidWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(order_id)
    order = Order.find(order_id)
    if (order.is_paid == false)
      order.update_column(:status, Order.statuses["訂單取消"])
      puts "已取消未付款訂單"
    end
    order.schedule.update_attribute(:is_execute, true)
  end
end