class ItemSpec < ActiveRecord::Base
  include AdminCartInformation

  RECOMMEND_STOCK = 5

  enum status: { on_shelf: 0, off_shelf: 1 }

  validates_numericality_of :style_amount, :only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true

  belongs_to :item
  has_one :stock_spec

  scope :recent, -> {order(id: :DESC)}
  scope :on_shelf, -> {where(status: ItemSpec.statuses[:on_shelf])}

  acts_as_paranoid
  mount_uploader :style_pic, SpecPicUploader

  def spec_id
    id
  end

  def add_to_cart_quantity
    quantity = ItemSpec::RECOMMEND_STOCK - stock_item_quantity - shipping_item_quantity
    quantity < 0 ? 0 : quantity
  end
end