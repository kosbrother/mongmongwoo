FactoryGirl.define do
  factory :exceed_quantity_percentage_off_campaign_rule, class: CampaignRule do
    title "指定商品購買超過xx件，打xx折"
    rule_type CampaignRule.rule_types["exceed_quantity"]
    discount_type CampaignRule.discount_types["percentage_off"]
    banner_cover { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'banner.png')) }
    card_icon { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'card_icon.png')) }
    list_icon { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'list_icon.png')) }
  end

  factory :exceed_amount_money_off_campaign_rule, class: CampaignRule do
    title "購買超過xx元，優惠xx元"
    rule_type CampaignRule.rule_types["exceed_amount"]
    discount_type CampaignRule.discount_types["money_off"]
    banner_cover { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'banner.png')) }
    card_icon { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'card_icon.png')) }
    list_icon { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'list_icon.png')) }
  end

  factory :exceed_amount_money_off_shopping_point_campaign_rule, class: CampaignRule do
    title "購買超過xx元，送購物金xx元"
    rule_type CampaignRule.rule_types["exceed_amount"]
    discount_type CampaignRule.discount_types["shopping_point"]
  end

  factory :exceed_quantity_buy_x_give_one_campaign_rule, class: CampaignRule do
    title "指定商品購買X件送一件"
    rule_type CampaignRule.rule_types["exceed_quantity"]
    discount_type CampaignRule.discount_types["get_one_free"]
    banner_cover { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'banner.png')) }
    card_icon { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'card_icon.png')) }
    list_icon { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'list_icon.png')) }
  end
end