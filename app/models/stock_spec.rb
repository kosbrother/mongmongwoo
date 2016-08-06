class StockSpec < ActiveRecord::Base
  include AdminCartInformation

  before_update :detect_amount_before_change
  after_update :set_item_spec_status

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

  def detect_amount_before_change
    @amount_before_change = StockSpec.find(id).amount
  end

  def replenish_empty_stock?
    @amount_before_change == 0 and amount > 0
  end

  def item_spec_able_on_shelf?
     item_spec.status == "off_shelf" and replenish_empty_stock?
  end

  def set_item_spec_status
    if stock_empty_and_stop_replenish?
      sef_item_spec_off_shelf
    elsif item_spec_able_on_shelf?
      set_item_spec_on_shelf
    end
  end
end