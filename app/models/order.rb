class Order < ActiveRecord::Base
  include OrderConcern
  include Combinable

  COMBINE_STATUS = ["新訂單", "處理中", "訂單變更"]
  RESTOCK_STATUS = ["未取訂貨", "退貨"]

  enum status: { "新訂單" => 0, "處理中" => 1, "配送中" => 2, "完成取貨" => 3, "訂單取消" => 4, "已到店" => 5, "訂單變更" => 6 ,"未取訂貨" => 7, "退貨" => 8 }

  validates_presence_of :user_id, :items_price, :ship_fee, :total

  after_update :update_stock_amount, if: :status_changed_to_shipping?

  belongs_to :user
  has_many :items, class_name: "OrderItem", dependent: :destroy
  has_one :info, class_name: "OrderInfo", dependent: :destroy, autosave: true
  belongs_to :device_registration
  has_many :mail_records, as: :recordable

  accepts_nested_attributes_for :info

  delegate :ship_store_code, :ship_store_name, :address, :ship_phone, :ship_name, :ship_email, :is_blacklisted, to: :info
  delegate :orders, to: :user, prefix: true

  scope :recent, -> { order(id: :DESC) }
  scope :count_status, ->(status) { where(status: status).count }
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  scope :cancelled_at_within, -> (time_param) { where(created_at: time_param, status: Order.statuses["訂單取消"]) }
  scope :status_count, -> { group(:status).size }
  scope :status, -> (status_param) { where(status: status_param) }
  scope :enable_to_conbime, -> { where(status: [Order.statuses["新訂單"], Order.statuses["處理中"], Order.statuses["訂單變更"]]) }

  acts_as_paranoid

  self.per_page = 50

  def self.search_by_search_terms(search_term)
    joins(:info).where('ship_phone = :ship_phone OR ship_email = :ship_email OR orders.id = :order_id', search_term).recent
  end

  def self.search_by_phone_or_email(phone, email)
    joins(:info).where('ship_phone = ? OR ship_email = ?', phone, email).recent
  end

  def self.daily_order_quantity_and_income
    result = created_at_within(Date.today.prev_day(1)..Date.today).select("COUNT(*) AS quantity, COALESCE(SUM(orders.items_price), 0) AS income")[0]
    [result["quantity"], result["income"]]
  end

  def self.to_csv(options={})
    CSV.generate(options) do |csv|
      csv << ["配送類別", "訂單類別", "取件人姓名", "取件人手機", "取件人電子郵件", "取件門市", "訂單金額"]
      all.each do |order|
        csv << ["K", "1", order.info_user_name, order.info_user_phone, "user@example.com", order.info_store_code, order.total]
      end
    end
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
    result_order[:created_on] = created_on
    result_order[:items_price] = items_price
    result_order[:ship_fee] = ship_fee
    result_order[:total] = total
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

  def created_at_for_api
    created_at.strftime("%Y-%m-%d")
  end

  def user_status_count(order_status)
    user_orders.where(status: order_status).count
  end

  def update_stock_amount
    items.each do |item|
      stock_spec = StockSpec.find_by(item_spec_id: item.item_spec_id)
      if stock_spec
        stock_spec.amount -= item.item_quantity
        stock_spec.save
      end
    end
  end

  def not_restock?
    Order::RESTOCK_STATUS.include?(status) && !is_return
  end

  def already_restock?
    Order::RESTOCK_STATUS.include?(status) && is_return
  end

  def restock_order_items
    items.each do |item|
      item.restock_amount
    end
  end

  private

  def status_changed_to_shipping?
    status_changed? && status == '配送中'
  end
end
