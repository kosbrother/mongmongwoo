class AdditionalPurchaseItem < ActiveRecord::Base
  belongs_to :item

  scope :recent, -> { order(id: :desc) }

  def price_reduction
    item.price - price
  end
end