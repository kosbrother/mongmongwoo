class StockSpec < ActiveRecord::Base
  include AdminCartInformation

  after_update :sef_item_spec_off_shelf, if: :stock_empty_and_stop_replenish?
  after_update :set_item_spec_on_shelf, if: :item_spec_able_on_shelf?

  scope :recent, -> { order(id: :DESC) }

  belongs_to :stock
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
    item_spec.update_attribute(:status, ItemSpec.statuses["on_shelf"])
  end

  def replenish_empty_stock?
    changed_attributes["amount"] == 0
  end

  def item_spec_able_on_shelf?
     item_spec.status == "off_shelf" and replenish_empty_stock?
  end
end