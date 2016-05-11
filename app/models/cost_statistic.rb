class CostStatistic < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }

  validates_presence_of :cost_of_goods, :cost_of_advertising, :cost_of_freight_in
  validates_numericality_of :cost_of_goods, :cost_of_advertising, :cost_of_freight_in, only_integer: true
end