class PriceManagerForCartItem
  attr_reader :id, :item, :item_spec, :origin_price, :item_quantity
  attr_accessor :subtotal, :discounted_price, :campaign_info, :gift_info

  def initialize(cart_item)
    @id = cart_item.id
    @item = cart_item.item
    @item_quantity = cart_item.item_quantity
    @origin_price = @item.special_price || @item.price
    @item_spec = cart_item.item_spec
    @discounted_price = @origin_price
    @subtotal = @origin_price * @item_quantity
    @campaign_info = nil
    @gift_info = nil

    campaign_rule = @item.campaign_rule
    if campaign_rule.present?
      apply_campaign_discount(campaign_rule)
    end
  end

  private

  def is_applied?(campaign_rule)
    campaign_rule.exceed_threshold?(quantity: @item_quantity)
  end

  def left_to_apply(campaign_rule)
    campaign_rule.left_to_apply(quantity: @item_quantity)
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
        subtotal = @item.price*1 + (@item.price*campaign_rule.discount_percentage)*(@item_quantity - 1)
        @discounted_price = (subtotal/@item_quantity).round
      elsif campaign_rule.discount_type == 'get_one_free'
        gift_quantity = @item_quantity/campaign_rule.threshold
        @gift_info = {item_name: @item.name, quantity: gift_quantity}
      end
      @subtotal = @discounted_price * @item_quantity
    end
    @campaign_info = campaign_info_and_result(campaign_rule)
  end
end