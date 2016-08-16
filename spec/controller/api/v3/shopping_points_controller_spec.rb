require 'spec_helper'

RSpec.describe Api::V3::ShoppingPointsController, :type => :controller do
  let!(:user) { FactoryGirl.create(:user) }

  describe "get#index" do
    let!(:shopping_point_campaign) { FactoryGirl.create(:shopping_point_campaign) }
    let!(:shopping_point) { FactoryGirl.create(:campaign_point, user: user, shopping_point_campaign: shopping_point_campaign) }
    let!(:shopping_point_first_record) { shopping_point.shopping_point_records.first }
    context "when user has many points" do
      it "does show all the points list" do
        get :index, user_id: user.id
        data = JSON.parse(response.body)["data"]

        expect(data["total"]).to eq(user.shopping_points.available.sum(:amount))
        expect(data["shopping_points"].length).to eq(user.shopping_points.size)
        expect(data["shopping_points"][0]["point_type"]).to eq(user.shopping_points.first.point_type)
        expect(data["shopping_points"][0]["amount"]).to eq(user.shopping_points.first.amount)
        expect(data["shopping_points"][0]["valid_until"]).to eq(user.shopping_points.first.valid_until.as_json)
        expect(data["shopping_points"][0]["shopping_point_campaign"]["description"]).to eq(shopping_point_campaign.description)
        expect(data["shopping_points"][0]["shopping_point_records"][0]).to eq(
          {
            "order_id"=>shopping_point_first_record.order_id,
            "amount"=>shopping_point_first_record.amount,
            "balance"=>shopping_point_first_record.balance,
            "created_at"=>shopping_point_first_record.created_at.as_json
          }
        )
      end
    end
  end
end