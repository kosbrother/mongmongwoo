class CampaignRulesController < ApplicationController
  layout 'user'
  before_action  :load_categories

  def index
    @campaign_rules = CampaignRule.valid

  end
end