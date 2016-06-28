class Stock < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }
  
  belongs_to :item
  has_many :stock_specs

  delegate :name, :price, :cost, :taobao_supplier_id, :cover, :url, to: :item
end