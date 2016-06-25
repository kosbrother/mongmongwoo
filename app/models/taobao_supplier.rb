class TaobaoSupplier < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }

  has_many :items
  has_many :stocks

  delegate :count, to: :items
end