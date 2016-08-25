require 'spec_helper'

describe Api::V4::ShoppingPointCampaignsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:shopping_point_campaign) { FactoryGirl.create(:shopping_point_campaign) }
  let!(:shopping_point) { FactoryGirl.create(:campaign_point, shopping_point_campaign: shopping_point_campaign, user: user, amount: shopping_point_campaign.amount) }
  describe "get#index" do
    context "when user_id is provided" do
      it "does show all the shopping_point_campaigns and status of user collection" do
        get :index, user_id: user.id
        last_shopping_point_campaigns = JSON.parse(response.body)["data"].last

        expect(last_shopping_point_campaigns["id"]).to eq(shopping_point_campaign.id)
        expect(last_shopping_point_campaigns["description"]).to eq(shopping_point_campaign.description)
        expect(last_shopping_point_campaigns["amount"]).to eq(shopping_point_campaign.amount)
        expect(last_shopping_point_campaigns["valid_until"]).to eq(shopping_point_campaign.valid_until.as_json)
        expect(last_shopping_point_campaigns["is_expired"]).to eq(shopping_point_campaign.is_expired)
        expect(last_shopping_point_campaigns["is_collected"]).to eq(true)
      end
    end
  end
end