class AddCampaignRuleIdToShoppingPointCampaigns < ActiveRecord::Migration
  def change
    add_column :shopping_point_campaigns, :campaign_rule_id, :integer
    add_index :shopping_point_campaigns, :campaign_rule_id
  end
end
