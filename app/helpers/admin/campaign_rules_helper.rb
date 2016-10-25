module Admin::CampaignRulesHelper
  def options_for_campaign_discount_types(discount_types)
    options_for_select(discount_types.map { |key| [t("models.campaign_rules.discount_type.#{key}"), key] })
  end

  def options_for_campaign_rule_types
    options_for_select(CampaignRule.rule_types.keys.map{|key| [t("models.campaign_rules.rule_type.#{key}"), key]})
  end
end
