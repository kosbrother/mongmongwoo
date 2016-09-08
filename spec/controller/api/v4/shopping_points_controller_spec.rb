require 'spec_helper'

RSpec.describe Api::V4::ShoppingPointsController, :type => :controller do
  let!(:user) { FactoryGirl.create(:user) }

  describe "get#index" do
    let!(:shopping_point_campaign) { FactoryGirl.create(:shopping_point_campaign) }
    let!(:shopping_point) { FactoryGirl.create(:campaign_point, user: user, amount: shopping_point_campaign.amount, shopping_point_campaign: shopping_point_campaign) }
    let!(:shopping_point_first_record) { shopping_point.shopping_point_records.first }
    let!(:shopping_point_amount) { ShoppingPointManager.new(user).total_amount }
    context "when user has many points" do
      it "does show all the points list" do
        get :index, user_id: user.id
        data = JSON.parse(response.body)["data"]
        last_shopping_point = user.shopping_points.last

        expect(data["total"]).to eq(shopping_point_amount)
        expect(data["shopping_points"].length).to eq(user.shopping_points.size)
        expect(data["shopping_points"].last["amount"]).to eq(last_shopping_point.amount)
        expect(data["shopping_points"].last["valid_until"]).to eq(last_shopping_point.valid_until.as_json)
        expect(data["shopping_points"].last["is_valid"]).to eq(last_shopping_point.is_valid)
        expect(data["shopping_points"].last["description"]).to eq(last_shopping_point.description)
        expect(data["shopping_points"].last["point_type"]).to eq(last_shopping_point.point_type)
        expect(data["shopping_points"].last["shopping_point_records"][0]).to eq(
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