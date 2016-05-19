class Order < ActiveRecord::Base
  include OrderConcern
  
  scope :recent, -> { order(id: :DESC) }
  scope :count_status, ->(status) { where(status: status).count }
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  scope :cancelled_at_within, -> (time_param) { where(created_at: time_param, status: Order.statuses["訂單取消"]) }
  scope :status_count, -> { group(:status).size }

  acts_as_paranoid

  enum status: { "新訂單" => 0, "處理中" => 1, "已出貨" => 2, "完成取貨" => 3, "訂單取消" => 4, "已到店" => 5, "訂單變更" => 6 ,"未取訂貨" => 7}

  belongs_to :user
  has_many :items, class_name: "OrderItem", dependent: :destroy
  has_one :info, class_name: "OrderInfo", dependent: :destroy
  belongs_to :device_registration

  self.per_page = 100

  delegate :ship_store_code, :ship_store_name, :address, :ship_phone, :ship_name, to: :info
  delegate :orders, to: :user, prefix: true

  def info_user_name
    user.user_name
  end

  def info_user_phone
    info.ship_phone
  end


  def generate_result_order(order, info, items)
    # 訂單資料
    result_order = {}
    result_order[:id] = order.id
    result_order[:uid] = order.uid
    result_order[:user_id] = order.user_id
    result_order[:status] = order.status
    result_order[:created_on] = order.created_on
    result_order[:items_price] = order.items_price
    result_order[:ship_fee] = order.ship_fee
    result_order[:total] = order.total
    result_order[:note] = order.note

    # 收件明細
    include_info = {}
    include_info[:id] = info.id
    include_info[:ship_name] = info.ship_name
    include_info[:ship_phone] = info.ship_phone
    include_info[:ship_store_code] = info.ship_store_code
    include_info[:ship_store_id] = info.ship_store_id
    include_info[:ship_store_name] = info.ship_store_name
    result_order[:info] = include_info

    # 商品明細
    include_items = []
    items.each do |item|
      item_hash = {}
      item_hash[:name] = item.item_name
      item_hash[:style] = item.item_style
      item_hash[:quantity] = item.item_quantity
      item_hash[:price] = item.item_price
      include_items << item_hash
    end
    result_order[:items] = include_items

    # 完整資料
    return result_order
  end

  def created_at_for_api
    self.created_at.strftime("%Y-%m-%d")
  end

  def self.to_csv(options={})
    CSV.generate(options) do |csv|
      csv << ["配送類別", "訂單類別", "取件人姓名", "取件人手機", "取件人電子郵件", "取件門市", "訂單金額"]
      all.each do |order|
        csv << ["K", "1", order.info_user_name, order.info_user_phone, "user@example.com", order.info_store_code, order.total]
      end
    end
  end

  def user_status_count(order_status)
    user_orders.where(status: order_status).count
  end
end