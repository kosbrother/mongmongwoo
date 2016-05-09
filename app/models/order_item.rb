class OrderItem < ActiveRecord::Base
  scope :sort_by_sales, -> { includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").order("sum_item_quantity DESC") }

  scope :sort_by_revenue, -> { includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").order("sum_item_revenue DESC") }
  
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }

  scope :product_sales_created_at, -> (item_id, time_param) { select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id, created_at: time_param) }
  scope :product_sales, -> (item_id){ select("SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id) }
  scope :product_style_sales, -> (item_id,spec_id){ select("SUM(item_quantity) as sum_item_quantity").where(source_item_id: item_id,item_spec_id: spec_id) }

  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"
  belongs_to :item_spec

  delegate :categories, to: :item

  validates_presence_of :source_item_id, allow_blank: true
end