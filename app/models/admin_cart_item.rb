class AdminCartItem < ActiveRecord::Base
  belongs_to :admin_cart
  belongs_to :item
  belongs_to :item_spec

  scope :recent, -> { order(id: :DESC) }
end
