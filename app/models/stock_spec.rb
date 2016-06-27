class StockSpec < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }

  belongs_to :stock
  belongs_to :item_spec

  delegate :style, :style_pic, to: :item_spec
end