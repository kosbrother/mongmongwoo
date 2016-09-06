require 'spec_helper'

describe Api::V4::ShoppingPointCampaignsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:shopping_point_campaign) { FactoryGirl.create(:shopping_point_campaign) }
  describe "get#index" do
    context "when the shopping_point campaign is collected" do
      let!(:shopping_point) { FactoryGirl.create(:campaign_point, shopping_point_campaign: shopping_point_campaign, user: user, amount: shopping_point_campaign.amount) }
      it "does show all the shopping_point_campaigns and status of user collection" do
        get :index, user_id: user.id
        data = JSON.parse(response.body)["data"]
        first_shopping_point_campaign = ShoppingPointCampaign.order(id: :desc).first

        expect(data.length).to eq(ShoppingPointCampaign.all.size)
        expect(data.first["id"]).to eq(first_shopping_point_campaign.id)
        expect(data.first["title"]).to eq(first_shopping_point_campaign.title)
        expect(data.first["description"]).to eq(first_shopping_point_campaign.description)
        expect(data.first["amount"]).to eq(first_shopping_point_campaign.amount)
        expect(data.first["created_at"]).to eq(first_shopping_point_campaign.created_at.as_json)
        expect(data.first["valid_until"]).to eq(first_shopping_point_campaign.valid_until.as_json)
        expect(data.first["is_expired"]).to eq(first_shopping_point_campaign.is_expired)
        expect(data.first["is_collected"]).to eq(true)
        expect(data.first["is_reusable"]).to eq(false)
      end
    end

    context "when the shopping_point campaign is not collected" do
      it "does show the shopping point campaign not collected" do
        get :index, user_id: user.id
        data = JSON.parse(response.body)["data"]

        expect(data.first["is_collected"]).to eq(false)
      end
    end
  end
end