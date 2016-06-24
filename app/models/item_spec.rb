class ItemSpec < ActiveRecord::Base
  scope :recent, -> {order(id: :DESC)}

  enum status: { on_shelf: 0, off_shelf: 1 }

  acts_as_paranoid

  belongs_to :item
  has_one :stock_spec
  has_many :shipping_items

  # validates_presence_of :style, :style_amount
  validates_numericality_of :style_amount, :only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true

  mount_uploader :style_pic, SpecPicUploader
end