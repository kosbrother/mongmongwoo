namespace :campaign_rule do
  task :check_valid_until => :environment do
    CampaignRule.valid.where.not(valid_until: nil).each do |campaign_rule|
      if campaign_rule.valid_until <= Time.current
        campaign_rule.update_column(:is_valid, false)
        campaign_rule.campaigns.destroy_all
      end
    end
  end
end