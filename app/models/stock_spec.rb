class StockSpec < ActiveRecord::Base
  include AdminCartInformation
  
  after_update :sef_item_spec_off_shelf, if: :stock_empty_and_stop_replenish?
  after_create :set_item_spec_on_shelf

  scope :recent, -> { order(id: :DESC) }

  belongs_to :item
  belongs_to :item_spec

  delegate :style, :style_pic, to: :item_spec

  def spec_id
    item_spec_id
  end

  private

  def sef_item_spec_off_shelf
    item_spec.update_attribute(:status, ItemSpec.statuses["off_shelf"])
  end

  def stock_empty_and_stop_replenish?
    amount == 0 and item_spec.is_stop_recommend == true
  end

  def set_item_spec_on_shelf
    if amount > 0
      item_spec.update_attribute(:status, ItemSpec.statuses["on_shelf"])
      item.update_attribute(:status, Item.statuses["on_shelf"])
    end
  end
end