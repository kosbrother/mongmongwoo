class AdminCart < ActiveRecord::Base
  scope :status, -> (status) { includes(:taobao_supplier, admin_cart_items: [:item, :item_spec]).where(status: status) }
  scope :recent, -> { order(id: :desc) }

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

  def confirm_cart_items_to_stocks
    ActiveRecord::Base.transaction do
      save_cart_item_to_stock
      self.update_attribute(:status, AdminCart::STATUS[:stock])
    end
  end

  private

  def save_cart_item_to_stock
    self.admin_cart_items.each do |cart_item|
      stock = Stock.find_or_create_by(item_id: cart_item.item_id)
      stock_spec = stock.stock_specs.find_or_create_by(item_spec_id: cart_item.item_spec_id)

      if stock_spec.amount.present?
        stock_spec.amount += cart_item.item_quantity
      else
        stock_spec.amount = cart_item.item_quantity
      end

      stock_spec.save
    end
  end
end