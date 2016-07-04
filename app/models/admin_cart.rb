class AdminCart < ActiveRecord::Base
  has_many :admin_cart_items, -> { order(id: :desc) }
  has_many :shipping_items
  belongs_to :taobao_supplier

  enum status: {'cart': 0, 'shipping': 1, 'stock': 2}

  STATUS = { cart: 0, shipping: 1, stock: 2 }

  def set_to_shipping
    if self.admin_cart_items.any?
      self.update_attribute(:status, AdminCart::STATUS[:shipping])
    end
  end

  def taobao_supplier_name
    if self.taobao_supplier.present?
      self.taobao_supplier.name
    else
      '未登記淘寶商家'
    end
  end
end
