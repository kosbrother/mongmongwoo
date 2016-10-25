require 'spec_helper'

RSpec.describe Api::V4::CampaignRulesController, :type => :controller do
  let!(:item) { FactoryGirl.create(:item_with_specs_and_photos, price: 100) }
  let!(:campaign_rule){ FactoryGirl.create(:exceed_quantity_percentage_off_campaign_rule, threshold: 3, discount_percentage: 0.9, valid_until: DateTime.now + 1.month  ) }
  let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule, discountable: item) }

  describe "get #index" do
    it "does reutrn correct data" do
      get :index
      data =  JSON.parse(response.body)['data']

      expect(data[0]['id']).to eq(campaign_rule.id)
      expect(data[0]['title']).to eq(campaign_rule.title)
      expect(data[0]['description']).to eq(campaign_rule.description)
      expect(data[0]['icon']['url']).to eq(campaign_rule.list_icon.url)
      expect(data[0]['created_at'].to_datetime.strftime('%Y-%m-%d %H:%M:%S')).to eq(campaign_rule.created_at.strftime('%Y-%m-%d %H:%M:%S'))
      expect(data[0]['valid_until'].to_datetime.strftime('%Y-%m-%d %H:%M:%S')).to eq(campaign_rule.valid_until.strftime('%Y-%m-%d %H:%M:%S'))
      expect(data[0]['app_index_url']).to eq(campaign_rule.app_index_url)
    end
  end

  describe "get#show" do
    it "does reutrn correct data" do
      get :show, id: campaign_rule.id
      data =  JSON.parse(response.body)['data']

      expect(data['image']).to eq(campaign_rule.banner_cover.as_json)
      expect(data['items'][0]['id']).to eq(item.id)
      expect(data['items'][0]['name']).to eq(item.name)
      expect(data['items'][0]['price']).to eq(item.price)
      expect(data['items'][0]['special_price']).to eq(item.special_price)
      expect(data['items'][0]['final_price']).to eq(item.final_price)
      expect(data['items'][0]['discount_icon_url']).to eq(item.discount_icon_url)
      expect(data['items'][0]['slug']).to eq(item.slug)
      expect(data['items'][0]['cover']['url']).to eq(item.cover_url)
    end
  end
end