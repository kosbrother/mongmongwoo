require 'rails_helper'

RSpec.describe Api::V3::StoresController, type: :controller do
  let!(:county) { FactoryGirl.create(:county) }
  let!(:town) { FactoryGirl.create(:town, county: county) }
  let!(:road) { FactoryGirl.create(:road, town: town) }
  let!(:store) { FactoryGirl.create(:store, county: county, town: town, road: road) }

  describe "Get index" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :index, county_id: county.id, town_id: town.id, road_id: road.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index, county_id: county.id, town_id: town.id, road_id: road.id }
    end

    it "should contain correct store data" do
      get :index, county_id: county.id, town_id: town.id, road_id: road.id
      json = JSON.parse(response.body)
      expect(json[0]['id']).to eq(store.id)
      expect(json[0]['name']).to eq(store.name)
      expect(json[0]['store_code']).to eq(store.store_code)
      expect(json[0]['address']).to eq(store.address)
      expect(json[0]['phone']).to eq(store.phone)
    end
  end
end