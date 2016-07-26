class ItemSpec < ActiveRecord::Base
  include AdminCartInformation

  enum status: { on_shelf: 0, off_shelf: 1 }

  validates_numericality_of :style_amount, :only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true

  belongs_to :item
  has_one :stock_spec

  scope :recent, -> {order(id: :DESC)}
  scope :on_shelf, -> {where(status: ItemSpec.statuses[:on_shelf])}
  scope :with_stock_amount, -> {joins('LEFT JOIN stock_specs on item_specs.id = stock_specs.item_spec_id').select('SUM(stock_specs.amount) as stock_amount').group('item_specs.id')}

  acts_as_paranoid
  mount_uploader :style_pic, SpecPicUploader

  def spec_id
    id
  end

  def add_to_cart_quantity
    quantity = recommend_stock_num - stock_item_quantity - shipping_item_quantity
    quantity < 0 ? 0 : quantity
  end

  def stock_amount
    stock_item_quantity
  end
end