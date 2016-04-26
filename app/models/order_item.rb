class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :item, :foreign_key => "source_item_id"

  delegate :categories, to: :item

  validates_presence_of :source_item_id, allow_blank: true
end