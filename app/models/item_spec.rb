class ItemSpec < ActiveRecord::Base
  include AdminCartInformation

  NEW_SPEC_RECOMMEND_STOCK_NUM = 1
  SHELF_POSITION = ("a".."z").to_a

  enum status: { on_shelf: 0, off_shelf: 1 }

  validates_numericality_of :style_amount, :only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true
  validates_presence_of :style, :style_pic

  after_update :update_recommend_stock_num, :update_item_status
  after_create :set_defult_recommend_stock_num, :add_shelf_position

  belongs_to :item
  has_one :stock_spec
  has_many :order_items
  has_many :admin_cart_items
  has_many :wish_lists
  has_many :messages, as: :messageable, dependent: :destroy

  scope :recent, -> {order(id: :DESC)}
  scope :on_shelf, -> {where(status: ItemSpec.statuses[:on_shelf])}
  scope :with_stock_amount, -> {joins('LEFT JOIN stock_specs on item_specs.id = stock_specs.item_spec_id').select('SUM(stock_specs.amount) as stock_amount').group('item_specs.id')}
  scope :recommend_stock_empty, -> {where(recommend_stock_num: 0, status: ItemSpec.statuses[:on_shelf], items: {status: Item.statuses["on_shelf"]}).order(item_id: :ASC)}

  acts_as_paranoid
  mount_uploader :style_pic, SpecPicUploader

  def spec_id
    id
  end

  def stock_amount
    amount = stock_item_quantity - requested_quantity
    (amount > 0) ? amount : 0
  end

  def item_shelf_position
    "#{item.shelf_position}-#{shelf_position}"
  end

  def sales_quantity
    order_items.sum(:item_quantity)
  end

  def sales_amount_within_days(number)
    OrderItem.where(created_at: TimeSupport.within_days(number)).select('COALESCE(SUM(order_items.item_quantity), 0)as sales_amount').find_by(item_spec_id: id).sales_amount
  end

  def sales_between(time_range)
    OrderItem.where(created_at: time_range, item_spec: self).sum(:item_quantity)
  end

  def wish_lists_num
    wish_lists.size
  end

  def wish_lists_num_within_days(number)
    wish_lists.where(created_at: TimeSupport.within_days(number)).size
  end

  def requested_quantity
    OrderItem.statuses_total_amount(id, Order::COMBINE_STATUS_CODE)
  end

  def purchase_quantity
    (recommend_stock_num + requested_quantity) - stock_item_quantity - shipping_item_quantity
  end

  private

  def status_change_to?(shelf_status)
    status_changed? && status == shelf_status
  end

  def update_recommend_stock_num
    update_column(:recommend_stock_num, 0) if status_change_to?("off_shelf")
  end

  def set_defult_recommend_stock_num
    update_column(:recommend_stock_num, ItemSpec::NEW_SPEC_RECOMMEND_STOCK_NUM)
  end

  def add_shelf_position
    update_column(:shelf_position, ItemSpec::SHELF_POSITION[item.specs.count - 1])
  end

  def update_item_status
    if status_change_to?("off_shelf") and (item.specs.on_shelf.size == 0)
      item.update_attribute(:status, Item.statuses["off_shelf"])
    end
  end
end