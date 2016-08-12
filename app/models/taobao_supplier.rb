class TaobaoSupplier < ActiveRecord::Base
  DEAFAULT_SUPPLIER_ID = TaobaoSupplier.last.id

  has_many :items

  delegate :count, :on_shelf, :off_shelf, to: :items

  scope :recent, -> { order(id: :DESC) }

  def item_ids_in_stock
    items.joins(:stock_specs).group(:id).map(&:id).join("，")
  end
end