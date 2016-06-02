require 'rails_helper'

RSpec.describe Api::V3::RoadsController, type: :controller do
  let!(:county) { FactoryGirl.create(:seven_store_county) }
  let!(:town) { FactoryGirl.create(:town, county: county) }
  let!(:road) { FactoryGirl.create(:road, town: town) }

  describe "Get index" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :index, county_id: county.id, town_id: town.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index, county_id: county.id, town_id: town.id }
    end

    it "should find town's roads" do
      get :index, county_id: county.id, town_id: town.id
      json = JSON.parse(response.body)
      expect(json.length).to eq(town.roads.length)
      expect(json[0]['id']).to eq(town.roads[0].id)
      expect(json[0]['name']).to eq(town.roads[0].name)
    end
  end
end