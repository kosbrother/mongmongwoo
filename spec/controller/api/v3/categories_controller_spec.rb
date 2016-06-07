require 'rails_helper'

RSpec.describe Api::V3::CategoriesController, type: :controller do
  describe "GET index" do
    let!(:some_category) { FactoryGirl.create(:category) }
    let!(:another_category) { FactoryGirl.create(:category) }

    it "should contain correct category quantity" do
      get :index
      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(Category.count)
    end

    it "should contain correct category data" do
      get :index
      data = JSON.parse(response.body)["data"]
      expect(data).to match_array(Category.select_api_fields.as_json)
    end
  end
end