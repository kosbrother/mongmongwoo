class AdminCart < ActiveRecord::Base
  scope :current_status, -> (status) { includes(:taobao_supplier, admin_cart_items: [:item, :item_spec]).where(status: status) }
  scope :recent, -> { order(id: :desc) }

  has_many :admin_cart_items, -> { order(id: :desc) }
  has_many :shipping_items
  belongs_to :taobao_supplier

  enum status: {'cart': 0, 'shipping': 1, 'stock': 2}

  STATUS = { cart: 0, shipping: 1, stock: 2 }
end
