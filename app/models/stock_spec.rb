class StockSpec < ActiveRecord::Base
  include AdminCartInformation

  after_update :sef_item_spec_off_shelf_if_stock_empty_and_stop_replenish, :send_wish_list_notification_if_stock_replenish
  after_create :set_on_shelf_and_send_wish_list_notification_when_amout_larger_than_zero
  before_save :print_changed_record_to_stock_spec_logger

  scope :recent, -> { order(id: :DESC) }

  belongs_to :item
  belongs_to :item_spec

  delegate :style, :style_pic, to: :item_spec

  def spec_id
    item_spec_id
  end

  private

  def sef_item_spec_off_shelf_if_stock_empty_and_stop_replenish
    item_spec.update_attribute(:status, ItemSpec.statuses["off_shelf"]) if stock_empty_and_stop_replenish?
  end

  def stock_empty_and_stop_replenish?
    amount == 0 and item_spec.is_stop_recommend == true
  end

  def set_item_spec_on_shelf
    item_spec.update_attribute(:status, ItemSpec.statuses["on_shelf"])
  end

  def set_on_shelf_and_send_wish_list_notification_when_amout_larger_than_zero
    if amount > 0
      set_item_spec_on_shelf
      UserNotifyService.wish_list_on_shelf(item_spec)
    end
  end

  def send_wish_list_notification_if_stock_replenish
    UserNotifyService.wish_list_arrival(item_spec) if amount_changed? && amount > 0
  end

  def print_changed_record_to_stock_spec_logger
    before_changed_amount = amount_was
    increments = amount - before_changed_amount
    operation = increments > 0 ? "+" : "-"
    message = "stock_spec_id: #{id}, item_spec_id: #{item_spec_id}, style: #{item_spec.style}, item_name: #{item.name}, Action: #{operation}#{increments.abs}, amount：#{amount}"
    StockSpecLogger.info(message)
  end
end