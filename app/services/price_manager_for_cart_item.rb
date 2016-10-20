class PriceManagerForCartItem
  attr_reader :item, :origin_price, :quantity
  attr_accessor :subtotal, :discounted_price, :campaign_info

  def initialize(cart_item)
    @item = cart_item.item
    @quantity = cart_item.item_quantity
    @origin_price = @item.special_price || @item.price
    @discounted_price = @origin_price
    @subtotal = @origin_price * @quantity
    @campaign_info = nil
  end

  def apply_item_campaign
    campaign_rule = @item.campaign_rule
    if campaign_rule.present?
      apply_campaign_discount(campaign_rule)
    end
  end

  private

  def is_applied?(campaign_rule)
    campaign_rule.exceed_threshold?(quantity: @quantity)
  end

  def left_to_apply(campaign_rule)
    campaign_rule.left_to_apply(quantity: @quantity)
  end

  def campaign_info_and_result(campaign_rule)
    campaign_info = {}
    campaign_info[:is_applied] = is_applied?(campaign_rule)
    campaign_info[:title] = campaign_rule.title
    campaign_info[:left_to_apply] = left_to_apply(campaign_rule)
    campaign_info
  end

  def apply_campaign_discount(campaign_rule)
    if is_applied?(campaign_rule)
      if campaign_rule.discount_type == 'percentage_off'
        @discounted_price = (@item.price*campaign_rule.discount_percentage).round
      elsif campaign_rule.discount_type == 'percentage_off_next'
        subtotal = @item.price*1 + (@item.price*campaign_rule.discount_percentage)*(@quantity - 1)
        @discounted_price = (subtotal/@quantity).round
      end
      @subtotal = @discounted_price * @quantity
    end
    @campaign_info = campaign_info_and_result(campaign_rule)
  end
end