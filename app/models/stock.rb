class Stock < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }
  
  belongs_to :taobao_supplier
  has_many :stock_specs
end