class Stock < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }
  scope :taobao_supplier_stocks, -> (taobao_supplier_id) { includes(:item, :stock_specs, stock_specs: [:item_spec]).where(items: { taobao_supplier_id: taobao_supplier_id }) }
  
  belongs_to :item
  has_many :stock_specs

  delegate :name, :price, :taobao_supplier_id, :cover, :url, :status, to: :item

  def cost
    if item.cost
      (self.item.cost * 5).round(2)
    else
      "尚未建立資料"
    end
  end
end