class OrderItem < ActiveRecord::Base
  scope :sort_by_sales, -> { 
    group(:source_item_id)
    .select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity")
    .order("sum_item_quantity DESC") }
  scope :sort_by_revenue, -> { 
    group(:source_item_id)
    .select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue")
    .order("sum_item_revenue DESC") }
  scope :with_supplier, -> (supplier_id) { joins("left join taobao_suppliers on taobao_suppliers.id = items.taobao_supplier_id").where(taobao_suppliers: { id: supplier_id })}
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  scope :product_sales_created_at, -> (item_id, time_param) { select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id, created_at: time_param) }
  scope :product_sales, -> (item_id){ select("SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id) }
  scope :product_style_sales, -> (item_id,spec_id){ select("SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id,item_spec_id: spec_id) }
  scope :total_income_and_cost, -> { joins(:item).select("COALESCE(SUM(order_items.item_quantity * order_items.item_price), 0) AS total_sales_income ", "COALESCE(SUM(order_items.item_quantity * items.cost), 0) AS total_cost_of_goods") }
  
  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"
  belongs_to :item_spec

  delegate :categories, :taobao_supplier, to: :item

  validates_presence_of :source_item_id, allow_blank: true
  validates_presence_of :item_name, :item_spec_id, :item_style, :item_quantity, :item_price

  def get_taobao_supplier_name
    item.supplier_name rescue "沒有商家資料"
  end
end