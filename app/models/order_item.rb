class OrderItem < ActiveRecord::Base
  validates_presence_of :source_item_id, allow_blank: true
  validates_presence_of :item_name, :item_spec_id, :item_style, :item_quantity, :item_price

  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"
  belongs_to :item_spec

  delegate :categories, :taobao_supplier, to: :item

  scope :sort_by_sales, -> { group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").order("sum_item_quantity DESC") }
  scope :sort_by_revenue, -> { group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").order("sum_item_revenue DESC") }
  scope :with_supplier, -> (supplier_id) { joins("left join taobao_suppliers on taobao_suppliers.id = items.taobao_supplier_id").where(taobao_suppliers: { id: supplier_id })}
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  scope :product_sales_created_at, -> (item_id, time_param) { select(:id, :item_name, :source_item_id, "COALESCE(SUM(item_quantity), 0) as sum_item_quantity").find_by(source_item_id: item_id, created_at: time_param) }
  scope :product_sales, -> (item_id){ select("COALESCE(SUM(item_quantity), 0) as sum_item_quantity").find_by(source_item_id: item_id) }
  scope :product_style_sales, -> (item_id,spec_id){ select("COALESCE(SUM(item_quantity), 0)as sum_item_quantity").find_by(source_item_id: item_id,item_spec_id: spec_id) }
  scope :total_income_and_cost, -> { joins(:item).select("COALESCE(SUM(order_items.item_quantity * order_items.item_price), 0) AS total_sales_income ", "COALESCE(SUM(order_items.item_quantity * items.cost), 0) AS total_cost_of_goods") }

  def self.requested_amount(item_spec_id)
    status_types = [Order.statuses['新訂單'], Order.statuses['處理中'], Order.statuses['訂單變更']]
    item_spec_id ? joins(:order).where(item_spec_id: item_spec_id, orders: { status: status_types }).sum(:item_quantity) : 0
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
    item_spec ? item_spec.shipping_amount : 0
  end
end