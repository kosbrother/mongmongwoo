class AdminCart < ActiveRecord::Base
  scope :status, -> (status) { includes(:taobao_supplier, admin_cart_items: [:item, :item_spec]).where(status: status) }
  scope :recent, -> { order(id: :desc) }

  has_many :admin_cart_items
  has_many :shipping_items
  belongs_to :taobao_supplier

  enum status: {'cart': 0, 'shipping': 1, 'stock': 2}
  
  STATUS = { cart: 0, shipping: 1, stock: 2 }

  def set_to_shipping
    if self.admin_cart_items.any?
      self.update_attributes(status:AdminCart::STATUS[:shipping], ordered_on: Time.current)
    end
  end

  def taobao_supplier_name
    if self.taobao_supplier.present?
      self.taobao_supplier.name
    else
      '未登記淘寶商家'
    end
  end

  def confirm_cart_items_to_stocks
    ActiveRecord::Base.transaction do
      save_cart_item_to_stock
      self.update_attributes(status: AdminCart::STATUS[:stock], confirmed_on: Time.current)
    end
  end

  private

  def save_cart_item_to_stock
    self.admin_cart_items.each do |cart_item|
      item = cart_item.item
      stock_spec = item.stock_specs.find_or_initialize_by(item_spec_id: cart_item.item_spec_id)
      stock_spec.amount += cart_item.real_item_quantity
      stock_spec.save
    end
  end
end