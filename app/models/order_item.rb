class OrderItem < ActiveRecord::Base
  scope :sort_by_sales, ->(time_field_params) { includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").where(created_at: time_from_now(time_field_params)).order("sum_item_quantity DESC") }

  scope :sort_by_revenue, ->(time_field_params) { includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").where(created_at: time_from_now(time_field_params)).order("sum_item_revenue DESC") }

  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"

  delegate :categories, to: :item

  validates_presence_of :source_item_id, allow_blank: true

  private

  def self.time_from_now(time_field_params)
    case time_field_params
    when "month"
      return (Time.now - 30.day)..Time.now
    when "week"
      return (Time.now - 7.day)..Time.now
    when "day"
      return (Time.now - 1.day)..Time.now
    end
  end
end