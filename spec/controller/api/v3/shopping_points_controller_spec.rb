require 'spec_helper'

RSpec.describe Api::V3::ShoppingPointsController, :type => :controller do
  let!(:user) { FactoryGirl.create(:user)}
  describe "get#index" do
    let!(:income_point) { FactoryGirl.create(:income_point, user_id: user.id) }
    let!(:spend_point) { FactoryGirl.create(:spend_point, user_id: user.id) }
    let!(:gift_point) { FactoryGirl.create(:gift_point, user_id: user.id) }
    context "when user has many points" do
      it "does show all the points list" do
        get :index, user_id: user.id
        data = JSON.parse(response.body)["data"]
        expect(data.length).to eq(user.shopping_points.size)
        expect(data[0]["id"]).to eq(user.shopping_points.first.id)
      end
    end
  end
end