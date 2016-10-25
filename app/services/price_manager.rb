class PriceManager

  def self.discount_amount(items_price)
    discountable_amount = 0
    campaigns = Campaign.money_off.includes(:campaign_rule)
    campaigns.each do |campaign|
      discountable_amount += campaign_discountable_amount(campaign.campaign_rule, items_price)
    end
    discountable_amount
  end

  def self.get_campaigns_for_order(items_price)
    campaigns = Campaign.money_off.includes(:campaign_rule)
    campaigns.map do |campaign|
      campaign_info_and_result(campaign.campaign_rule, items_price)
    end
  end

  def self.obtain_shopping_point_amount(items_price)
    shopping_point_amount = 0
    shopping_point_campaigns = ShoppingPointCampaign.with_campaign_rule.includes(:campaign_rule)
    shopping_point_campaigns.each do |shopping_point_campaign|
      shopping_point_amount += shopping_point_obtainable_amount(shopping_point_campaign, items_price)
    end
    shopping_point_amount
  end

  def self.return_shopping_point_campaigns(items_price)
    shopping_point_campaigns = ShoppingPointCampaign.with_campaign_rule.includes(:campaign_rule)
    shopping_point_campaigns.map do |shopping_point_campaign|
      campaign_info_and_result(shopping_point_campaign.campaign_rule, items_price)
    end
  end

  def self.count_ship_fee(items_price)
    if items_price >= Cart::FREE_SHIPPING_PRICE
      0
    else
      Cart::SHIP_FEE
    end
  end

  def self.get_free_ship_campaign(items_price)
    items_price >= Cart::FREE_SHIPPING_PRICE  ? left_to_apply = 0 : left_to_apply = Cart::FREE_SHIPPING_PRICE - items_price
    {left_to_apply: left_to_apply, title: "滿#{Cart::FREE_SHIPPING_PRICE}免運費"}
  end

  private

  def self.is_applied?(campaign_rule, items_price)
    campaign_rule.exceed_threshold?(amount: items_price)
  end

  def self.campaign_discountable_amount(campaign_rule, items_price)
    is_applied?(campaign_rule, items_price) ? campaign_rule.discount_money :  0
  end

  def self.shopping_point_obtainable_amount(shopping_point_campaign, items_price)
    is_applied?(shopping_point_campaign.campaign_rule, items_price) ? shopping_point_campaign.amount : 0
  end

  def self.campaign_info_and_result(campaign_rule, items_price)
    campaign_info = {}
    campaign_info[:campaign_rule_id] = campaign_rule.id
    campaign_info[:is_applied] = is_applied?(campaign_rule, items_price)
    campaign_info[:title] = campaign_rule.title
    campaign_info[:left_to_apply] = campaign_rule.left_to_apply(amount: items_price)
    campaign_info[:discount_amount] = campaign_discountable_amount(campaign_rule, items_price) if campaign_rule.discount_type == 'money_off'
    campaign_info
  end
end