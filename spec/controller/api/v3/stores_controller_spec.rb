require 'rails_helper'

RSpec.describe Api::V3::StoresController, type: :controller do
  let!(:county) { FactoryGirl.create(:seven_store_county) }
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

    it "should contain corrcet road's stores quantity" do
      get :index, county_id: county.id, town_id: town.id, road_id: road.id
      data = JSON.parse(response.body)["data"]
      expect(data.length).to eq(road.stores.length)
    end

    it "should contain correct store data" do
      get :index, county_id: county.id, town_id: town.id, road_id: road.id
      data = JSON.parse(response.body)["data"]
      expect(data[0]['id']).to eq(road.stores[0].id)
      expect(data[0]['name']).to eq(road.stores[0].name)
      expect(data[0]['store_code']).to eq(road.stores[0].store_code)
      expect(data[0]['address']).to eq(road.stores[0].address)
      expect(data[0]['phone']).to eq(road.stores[0].phone)
      expect(data[0]['lat']).to eq(road.stores[0].lat.to_s)
      expect(data[0]['lng']).to eq(road.stores[0].lng.to_s)
    end
  end
end