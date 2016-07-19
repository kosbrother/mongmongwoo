class ItemSpec < ActiveRecord::Base
  include AdminCartInformation

  scope :recent, -> {order(id: :DESC)}
  scope :on_shelf, -> {where(status: ItemSpec.statuses[:on_shelf])}

  RECOMMEND_STOCK = 5

  enum status: { on_shelf: 0, off_shelf: 1 }

  belongs_to :item
  has_one :stock_spec

  validates_numericality_of :style_amount, :only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true

  acts_as_paranoid
  mount_uploader :style_pic, SpecPicUploader

  def spec_id
    id
  end
end