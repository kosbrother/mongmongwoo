require 'rails_helper'

RSpec.describe Api::V3::CategoriesController, type: :controller do
  let(:all_items) { FactoryGirl.create(:category) }
  let(:new_items) { FactoryGirl.create(:category) }
  let!(:categories) { [all_items, new_items] }

  describe "GET index" do
    it "should contain correct category quantity" do
      get :index
      json = JSON.parse(response.body)
      expect(json.length).to eq(categories.length)
    end

    it "should contain correct category data" do
      get :index
      json = JSON.parse(response.body)
      expect(json[0]['id']).to eq(categories[0].id)
      expect(json[0]['name']).to eq(categories[0].name)
      expect(json[1]['id']).to eq(categories[1].id)
      expect(json[1]['name']).to eq(categories[1].name)
    end
  end
end