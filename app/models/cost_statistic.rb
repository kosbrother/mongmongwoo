class CostStatistic < ActiveRecord::Base
  scope :by_cost_date_recent, -> { order(cost_date: :DESC) }
  scope :cost_date_within, -> (time_param) { where(cost_date: time_param) }

  validates_presence_of :cost_of_goods, :cost_of_advertising, :cost_of_freight_in
  validates_numericality_of :cost_of_goods, :cost_of_advertising, :cost_of_freight_in, only_integer: true
end