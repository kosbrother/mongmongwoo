class OrderItem < ActiveRecord::Base
  validates_presence_of :item_name, :item_spec_id, :item_style, :item_quantity, :item_price, :source_item_id
  validate :product_able_to_buy
  validates_numericality_of :item_quantity, greater_than: 0

  belongs_to :order
  belongs_to :item, -> { with_deleted}, :foreign_key => "source_item_id"
  belongs_to :item_spec, -> { with_deleted}

  delegate :categories, :taobao_supplier, to: :item

  scope :sort_by_sales, -> { group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").order("sum_item_quantity DESC") }
  scope :sort_by_revenue, -> { group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").order("sum_item_revenue DESC") }
  scope :with_supplier, -> (supplier_id) { joins("left join taobao_suppliers on taobao_suppliers.id = items.taobao_supplier_id").where(taobao_suppliers: { id: supplier_id })}
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  scope :total_income_and_cost, -> { joins(:item).select("COALESCE(SUM(order_items.item_quantity * order_items.item_price), 0) AS total_sales_income ", "COALESCE(SUM(order_items.item_quantity * items.cost), 0) AS total_cost_of_goods") }
  scope :by_shelf_position, -> { joins(:item).order("items.shelf_position ASC") }
  scope :by_source_item, -> { order(source_item_id: :ASC) }

  acts_as_paranoid

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
    item_spec ? item_spec.stock_item_quantity : 0
  end

  def shipping_amount
    item_spec ? item_spec.shipping_item_quantity : 0
  end

  def restock_item
    stock_spec = item_spec.stock_spec || item.stock_specs.create(item_spec: item_spec)
    stock_spec.amount += item_quantity
    stock_spec.save
    update_attribute(:restock, true)
  end

  def able_to_pack?
    (stock_amount - OrderItem.statuses_total_amount(item_spec_id, Order::OCCUPY_STOCK_STATUS_CODE)) >= item_quantity
  end

  def stock_amount_enough?
    item_spec = ItemSpec.find(item_spec_id)
    item_spec.stock_amount >= item_quantity
  end

  def item_spec_on_shelf?
    spec = ItemSpec.find(item_spec_id)
    spec.status == "on_shelf"
  end

  def item_on_shelf?
    item.status == "on_shelf"
  end

  private

  def able_to_buy?
    stock_amount_enough? && item_spec_on_shelf?
  end

  def unable_to_buy_error
    data = {}
    item = Item.find(source_item_id)
    data = item.as_json(only: [:id, :name])
    data.delete_if {|k| k == :final_price}
    spec = item.specs.select(:id,:style,:style_pic,:status).with_stock_amount.find(item_spec_id)
    data[:spec] = spec
    data[:quantity_to_buy] = item_quantity
    errors[:unable_to_buy] = data
  end

  def product_able_to_buy
    unable_to_buy_error unless able_to_buy?
  end
end