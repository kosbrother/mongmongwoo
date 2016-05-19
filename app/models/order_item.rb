class OrderItem < ActiveRecord::Base
  scope :sort_by_sales, -> { joins(:item, item: [:categories]).joins("left join taobao_suppliers on taobao_suppliers.id = items.taobao_supplier_id").group(:source_item_id)
    .select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity")
    .order("sum_item_quantity DESC") }
  scope :with_supplier, -> (supplier_id){ where(taobao_suppliers: { id: supplier_id })}
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }
  # scope :get_item_sales, -> (params) do
  #   sort_by_sales(params)
  # end

  scope :get_item_sales, -> (params) do
    sort_by_sales
    with_supplier(params[:supplier_id]) if params[:supplier_id]
    # created_at_within(time_until_range(params[:time_field])) if params[:time_field]
  end
  # scope :sort_by_sales, -> { includes(:item, item: [:categories, :taobao_supplier]).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").order("sum_item_quantity DESC") }
  # scope :sort_by_revenue, -> { includes(:item, item: [:categories, :taobao_supplier]).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").order("sum_item_revenue DESC") }
  
  scope :product_sales_created_at, -> (item_id, time_param) { select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id, created_at: time_param) }
  scope :product_sales, -> (item_id){ select("SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id) }
  scope :product_style_sales, -> (item_id,spec_id){ select("SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id,item_spec_id: spec_id) }
  scope :total_sales_income, -> { sum("item_quantity * item_price") }

  # scope :sort_by_sales_with_taobao_supplier, -> (supplier_id) { joins(:item, item: [:categories, :taobao_supplier]).select(:id, :source_item_id, :item_name, "SUM(item_quantity) as sum_item_quantity").where(taobao_suppliers: { id: supplier_id }) }
  # scope :sort_by_revenue_with_taobao_supplier, -> (supplier_id) { joins(:item, item: [:categories, :taobao_supplier]).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").where(taobao_suppliers: { id: supplier_id }) }
  
  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"
  belongs_to :item_spec

  delegate :categories, :taobao_supplier, to: :item

  validates_presence_of :source_item_id, allow_blank: true

  def get_taobao_supplier_name
    item.supplier_name rescue "沒有商家資料"
  end

  def time_until_range(time_field)
    TimeSupport.time_until(time_field)
  end
end