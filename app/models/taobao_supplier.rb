class TaobaoSupplier < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }

  has_many :items
  has_many :stocks

  delegate :count, to: :items

  def item_ids_in_stock
    items.joins(:stock).map(&:id).join("，")
  end
end