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
      expect(data[0]["id"]).to eq(Category.all[0]["id"])
      expect(data[0]["name"]).to eq(Category.all[0]["name"])
      expect(data[0]["image"]["url"]).to eq(Category.all[0].image_url)
      expect(data[1]["id"]).to eq(Category.all[1]["id"])
      expect(data[1]["name"]).to eq(Category.all[1]["name"])
      expect(data[1]["image"]["url"]).to eq(Category.all[1].image_url)
    end
  end
end