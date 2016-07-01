class Stock < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }
  
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