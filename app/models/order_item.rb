class OrderItem < ActiveRecord::Base
  scope :sort_by_sales, -> { includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").order("sum_item_quantity DESC") }
  scope :sort_by_revenue, -> { includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").order("sum_item_revenue DESC") }
  scope :created_at_within, -> (time_param) { where(created_at: time_param) }

  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"

  delegate :categories, to: :item

  validates_presence_of :source_item_id, allow_blank: true

  # private

  # def self.time_within(time_param)
  #   case time_param
  #   when "month"
  #     return (Time.now - 30.day)..Time.now
  #   when "week"
  #     return (Time.now - 7.day)..Time.now
  #   when "day"
  #     return (Time.now - 1.day)..Time.now
  #   end
  # end
end