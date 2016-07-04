module Combinable
  extend ActiveSupport::Concern
  included do
    def self.combine_orders(order_ids)
      combine_orders = self.where(id: order_ids)
      ActiveRecord::Base.transaction do
        order = self.create_combined_order(combine_orders)
        order_info = combine_orders.find_by(user_id: order.user_id).info
        order_items = combine_orders.map(&:items).flatten
        order.create_combined_order_info(order_info)
        order.create_combined_items(order_items)
      end
      combine_orders.each { |order| order.update_column(:status, Order.statuses["訂單取消"]) }
    end

    def self.create_combined_order(orders)
      combined_items_price = orders.map(&:items_price).inject(:+)
      combined_ship_fee = combined_items_price > Cart::FREE_SHIPPING_PRICE ? 0 : Cart::SHIP_FEE
      combined_total = combined_items_price + combined_ship_fee
      login_user_order = orders.where.not(user_id: User::ANONYMOUS).first
      order = Order.new
      if login_user_order.present?
        order.uid = login_user_order.uid
        order.user_id = login_user_order.user_id
        order.device_registration_id = login_user_order.device_registration_id
      else
        order.uid = orders[0].uid
        order.user_id = orders[0].user_id
        order.device_registration_id = orders[0].device_registration_id
      end
      order.items_price = combined_items_price
      order.ship_fee = combined_ship_fee
      order.total = combined_total
      order.note = "訂單編號：#{orders.map(&:id).join('，')} 併單"
      order.save
      order
    end
  end

  def create_combined_order_info(order_info)
    info = OrderInfo.new
    info.order_id = self.id
    info.ship_name = order_info.ship_name
    info.ship_phone = order_info.ship_phone
    info.ship_store_code = order_info.ship_store_code
    info.ship_store_id = order_info.ship_store_id
    info.ship_store_name = order_info.ship_store_name
    info.ship_email = order_info.ship_email
    info.save
  end

  def create_combined_items(items)
    items.each do |product|
      item = self.items.new
      item.item_name = product.item.name
      item.source_item_id = product.source_item_id
      item.item_spec_id = product.item_spec_id
      item.item_style = product.item_spec.style
      item.item_quantity = product.item_quantity
      item.item_price = product.item.price
      item.save
    end
  end
end