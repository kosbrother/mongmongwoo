class OrderItem < ActiveRecord::Base
  validates_presence_of :source_item_id, allow_blank: true
  validates_presence_of :item_name, :item_spec_id, :item_style, :item_quantity, :item_price
  validate :product_able_to_buy

  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"
  belongs_to :item_spec

  delegate :categories, :taobao_supplier, to: :item

  scope :sort_by_sales, -> { group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").order("sum_item_quantity DESC") }
  scope :sort_by_revenue, -> { group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").order("sum_item_revenue DESC") }
  scope :with_supplier, -> (supplier_id) { joins("left join taobao_suppliers on taobao_suppliers.id = items.taobao_supplier_id").where(taobao_suppliers: { id: supplier_id })}
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  scope :total_income_and_cost, -> { joins(:item).select("COALESCE(SUM(order_items.item_quantity * order_items.item_price), 0) AS total_sales_income ", "COALESCE(SUM(order_items.item_quantity * items.cost), 0) AS total_cost_of_goods") }

  def self.statuses_total_amount(item_spec_id, statuses=[])
    item_spec_id ? joins(:order).where(item_spec_id: item_spec_id, orders: { status: statuses }).sum(:item_quantity) : 0
  end

  def subtotal
    item_quantity * item_price
  end

  def get_taobao_supplier_name
    item.taobao_supplier_id ? item.supplier_name : "沒有商家資料"
  end

  def stock_amount
    item_spec ? item_spec.stock_amount : 0
  end

  def shipping_amount
    item_spec ? item_spec.shipping_item_quantity : 0
  end

  def find_item_spec
    item.specs.find_by(style: item_style)
  end

  def find_or_create_stock_spec(item_spec)
    item.stock_specs.find_or_create_by(item_spec_id: item_spec.id)
  end

  def restock_amount
    spec = item_spec || find_item_spec
    stock_spec = spec.stock_spec || find_or_create_stock_spec(spec)
    stock_spec.amount += item_quantity
    stock_spec.save
    update_attribute(:restock, true)
  end

  def able_to_pack?
    (stock_amount - OrderItem.statuses_total_amount(item_spec_id, Order::OCCUPY_STOCK_STATUS_CODE)) >= item_quantity
  end

  def stock_amount_enough?
    stock_spec = StockSpec.find_by(item_spec_id: item_spec_id)
    stock_spec.amount >= item_quantity
  end

  def item_spec_on_shelf?
    spec = ItemSpec.find(item_spec_id)
    spec.status == "on_shelf"
  end

  def able_to_buy?
    stock_amount_enough? && item_spec_on_shelf?
  end

  def unable_to_buy_error
    errors[:unable_to_buy] = { product_id: source_item_id.to_s, spec_id: item_spec_id.to_s, stock_amount: item_spec.stock_spec.amount.to_s, status: item_spec.status }
  end

  def product_able_to_buy
    unable_to_buy_error unless able_to_buy?
  end
end