class TaobaoSupplier < ActiveRecord::Base
  has_many :items
  has_many :stocks

  delegate :count, to: :items

  scope :recent, -> { order(id: :DESC) }

  def item_ids_in_stock
    items.joins(:stock).map(&:id).join("，")
  end
end