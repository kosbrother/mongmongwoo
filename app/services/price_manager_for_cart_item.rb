class PriceManagerForCartItem
  attr_reader :item, :origin_price, :quantity
  attr_accessor :subtotal, :discounted_price, :campaigns_info

  def initialize(cart_item)
    @item = cart_item.item
    @quantity = cart_item.item_quantity
    @origin_price = cart_item.item.final_price
    @discounted_price = @origin_price
    @subtotal = @origin_price * @quantity
    @campaigns_info = []
  end

  def apply_item_campaign
    campaigns = Campaign.percentage_off(@item)
    campaigns.each do |campaign|
      campaign_rule =campaign.campaign_rule
      @subtotal = apply_campaign_discount(campaign_rule)
      @discounted_price = (@subtotal / @quantity).round
      @campaigns_info << campaign_info_and_result(campaign_rule)
    end
  end

  private

  def is_applied?(campaign_rule)
    campaign_rule.exceed_threshold?(quantity: @quantity, amount: @subtotal)
  end

  def left_to_apply(campaign_rule)
    campaign_rule.left_to_apply(quantity: @quantity, amount: @subtotal)
  end

  def apply_campaign_discount(campaign_rule)
    is_applied?(campaign_rule) ? campaign_rule.apply_discount(amount: @subtotal, quantity: @quantity) :  @subtotal
  end

  def campaign_info_and_result(campaign_rule)
    campaign_info = {}
    campaign_info[:is_applied] = is_applied?(campaign_rule)
    campaign_info[:title] = campaign_rule.title
    campaign_info[:left_to_apply] = left_to_apply(campaign_rule)
    campaign_info
  end
end