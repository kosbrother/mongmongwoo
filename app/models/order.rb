class Order < ActiveRecord::Base
  include OrderConcern
  include CalculatePrice

  enum status: { "新訂單" => 0, "處理中" => 1, "配送中" => 2, "完成取貨" => 3, "訂單取消" => 4, "已到店" => 5, "訂單變更" => 6 ,"未取訂貨" => 7, "退貨" => 8 }

  COMBINE_STATUS = ["新訂單", "處理中", "訂單變更"]
  RESTOCK_STATUS = ["未取訂貨", "退貨"]
  OCCUPY_STOCK_STATUS = ["處理中", "訂單變更"]
  CANCELABLE_STATUS = ["新訂單", "處理中"]
  FAIL_STATUS = ["訂單取消", "未取訂單", "退貨"]
  SHOW_BARCODE_STATUS = ["配送中", "訂單變更"]
  COMBINE_STATUS_CODE = Order::COMBINE_STATUS.map{|status| Order.statuses[status]}
  OCCUPY_STOCK_STATUS_CODE = Order::OCCUPY_STOCK_STATUS.map{|status| Order.statuses[status]}

  validates_presence_of :user_id, :items_price, :ship_fee, :total
  validates_numericality_of :items_price, :total, greater_than: 0


  after_update :reduce_stock_amount_if_status_shipping, :restock_if_status_changed_from_shipping

  belongs_to :user
  has_many :items, class_name: "OrderItem", dependent: :destroy
  has_one :info, class_name: "OrderInfo", dependent: :destroy, autosave: true
  belongs_to :device_registration
  has_many :mail_records, as: :recordable
  has_many :shopping_point_records

  accepts_nested_attributes_for :info

  delegate :ship_store_code, :ship_store_name, :address, :ship_phone, :ship_name, :ship_email, to: :info
  delegate :orders, to: :user, prefix: true

  scope :recent, -> { order(id: :DESC) }
  scope :count_status, ->(status) { where(status: status).count }
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  scope :cancelled_at_within, -> (time_param) { where(created_at: time_param, status: Order.statuses["訂單取消"]) }
  scope :status_count, -> { group(:status).size }
  scope :status, -> (status_param) { where(status: status_param) }
  scope :nil_logistics_code, -> {where('logistics_status_code is NULL')}
  scope :allpay_transfer_id_present, -> { where('orders.allpay_transfer_id IS NOT NULL') }
  scope :count_and_income_fields, -> { select("COUNT(*) AS quantity, COALESCE(SUM(orders.items_price), 0) AS income") }

  acts_as_paranoid

  self.per_page = 20

  def self.search_by_search_terms(search_term)
    joins(:info).where('ship_phone = :ship_phone OR ship_email = :ship_email OR orders.id = :order_id', search_term).recent
  end

  def self.search_by_phone_or_email(phone, email)
    joins(:info).where('ship_phone = ? OR ship_email = ?', phone, email).recent
  end

  def survey_mail
    mail_records.find_by(mail_type: MailRecord.mail_types["satisfaction_survey"])
  end

  def info_user_name
    user.user_name
  end

  def info_user_phone
    info.ship_phone
  end

  def get_user_name
    user_id == User::ANONYMOUS || info_user_name.nil? ? '顧客' : info_user_name
  end

  def generate_result_order
    result_order = {}
    result_order[:id] = id
    result_order[:uid] = uid
    result_order[:user_id] = user_id
    result_order[:status] = status
    result_order[:created_on] = created_at
    result_order[:items_price] = items_price
    result_order[:ship_fee] = ship_fee
    result_order[:total] = total
    result_order[:shopping_point_amount] = shopping_point_spend_amount
    result_order[:note] = note

    include_info = {}
    include_info[:id] = info.id
    include_info[:ship_name] = info.ship_name
    include_info[:ship_phone] = info.ship_phone
    include_info[:ship_email] = info.ship_email
    include_info[:ship_store_code] = info.ship_store_code
    include_info[:ship_store_id] = info.ship_store_id
    include_info[:ship_store_name] = info.ship_store_name
    include_info[:ship_store_address] = info.address
    include_info[:ship_store_phone] = info.phone
    result_order[:info] = include_info

    include_items = []
    items.each do |item|
      item_hash = {}
      item_hash[:name] = item.item_name
      item_hash[:style] = item.item_style
      item_hash[:quantity] = item.item_quantity
      item_hash[:price] = item.item_price
      item_hash[:style_pic] = item.item_spec ? item.item_spec.style_pic_url : nil
      include_items << item_hash
    end
    result_order[:items] = include_items

    result_order
  end

  def user_status_count(order_status)
    user_orders.where(status: order_status).count
  end

  def restock_order_items
    ActiveRecord::Base.transaction do
      items.each do |item|
        item.restock_item
      end
    end
    update_column(:restock, true)
  end

  def all_able_to_pack?
    items.all? { |item| item.able_to_pack? }
  end

  def cancel_able?
    Order::CANCELABLE_STATUS.include?(status)
  end

  def m_items
    items
  end

  def shopping_point_spend_amount
    shopping_point_records.where('shopping_point_records.amount < 0').sum(:amount).abs
  end

  def changed_order_id
    time = created_at.strftime("%Y%m%d")
    changed_id = id.to_s + time
    changed_id.to_i
  end

  private

  def status_changed_to?(changed_status)
    status_changed? && status == changed_status
  end

  def reduce_stock_amount_if_status_shipping
    if status_changed_to?("配送中")
      items.each do |item|
        stock_spec = StockSpec.find_by(item_spec_id: item.item_spec_id)
        if stock_spec
          stock_spec.amount -= item.item_quantity
          stock_spec.save
        end
      end
    end
  end

  def restock_if_status_changed_from_shipping
    if status_changed_to?("訂單變更") && status_was == "配送中"
      items.each do |item|
        stock_spec = StockSpec.find_by(item_spec_id: item.item_spec_id)
        if stock_spec
          stock_spec.amount += item.item_quantity
          stock_spec.save
        end
      end
    end
  end
end
