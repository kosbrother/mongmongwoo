require 'rails_helper'

RSpec.describe Api::V4::CategoriesController, type: :controller do
  describe "GET index" do
    let!(:some_category) { FactoryGirl.create(:category) }
    let!(:child_category) { FactoryGirl.create(:category, parent_id: some_category.id) }

    before :each do
      get :index
    end

    it "should contain correct category quantity" do
      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(Category.parent_categories.count)
    end

    it "should contain correct category data" do
      data = JSON.parse(response.body)["data"]
      expect(data[0]["id"]).to eq(some_category.id)
      expect(data[0]["name"]).to eq(some_category.name)
      expect(data[0]["image"]["url"]).to eq(some_category.image_url)
    end

    it "should contain correct child_categories" do
      data = JSON.parse(response.body)["data"]
      expect(data[0]["child_categories"].count).to eq(some_category.child_categories.count)
      expect(data[0]["child_categories"][0]["id"]).to eq(child_category.id)
      expect(data[0]["child_categories"][0]["name"]).to eq(child_category.name)
      expect(data[0]["child_categories"][0]["image"]["url"]).to eq(child_category.image_url)
    end
  end
end