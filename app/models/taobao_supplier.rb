class TaobaoSupplier < ActiveRecord::Base
  has_many :items
  has_many :stocks

  delegate :count, :on_shelf, :off_shelf, to: :items

  scope :recent, -> { order(id: :DESC) }
  scope :count_items_by_status, -> { joins(:items).group(:status).count }

  def item_ids_in_stock
    items.joins(:stock).map(&:id).join("，")
  end
end