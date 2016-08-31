require 'spec_helper'

describe Api::V4::ShoppingPointCampaignsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:shopping_point_campaign) { FactoryGirl.create(:shopping_point_campaign) }
  let!(:shopping_point) { FactoryGirl.create(:campaign_point, shopping_point_campaign: shopping_point_campaign, user: user, amount: shopping_point_campaign.amount) }
  describe "get#index" do
    context "when user_id is provided" do
      it "does show all the shopping_point_campaigns and status of user collection" do
        get :index, user_id: user.id
        data = JSON.parse(response.body)["data"]
        first_shopping_point_campaign = ShoppingPointCampaign.all.first

        expect(data.length).to eq(ShoppingPointCampaign.all.size)
        expect(data.last["id"]).to eq(first_shopping_point_campaign.id)
        expect(data.last["title"]).to eq(first_shopping_point_campaign.title)
        expect(data.last["description"]).to eq(first_shopping_point_campaign.description)
        expect(data.last["amount"]).to eq(first_shopping_point_campaign.amount)
        expect(data.last["created_at"]).to eq(first_shopping_point_campaign.created_at.as_json)
        expect(data.last["valid_until"]).to eq(first_shopping_point_campaign.valid_until.as_json)
        expect(data.last["is_expired"]).to eq(first_shopping_point_campaign.is_expired)
        expect(data.last["is_collected"]).to eq(true)
      end
    end
  end
end