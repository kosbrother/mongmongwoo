class StockSpec < ActiveRecord::Base
  include AdminCartInformation

  after_update :sef_item_spec_off_shelf_if_stock_empty_and_stop_replenish, :notify_wish_list_item_spec_arrival_if_stock_replenish
  after_create :set_on_shelf_when_amout_larger_than_zero

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

  def set_on_shelf_when_amout_larger_than_zero
    set_item_spec_on_shelf if amount > 0
  end

  def notify_wish_list_item_spec_arrival_if_stock_replenish
    if amount_changed? && amount > 0
      users = UserFinder.find_wish_lists_users(item_spec)
      users.find_each do |user|
        UserNotifyService.new(user).wish_list_item_spec_arrival(item_spec) unless user.wish_list_item_message_present?
      end
    end
  end
end