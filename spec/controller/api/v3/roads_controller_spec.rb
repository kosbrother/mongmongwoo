require 'rails_helper'

RSpec.describe Api::V3::RoadsController, type: :controller do
  describe "Get index" do
    let!(:county) { FactoryGirl.create(:seven_store_county) }
    let!(:town) { FactoryGirl.create(:town, county: county) }
    let!(:road) { FactoryGirl.create(:road, town: town) }
    
    it_behaves_like "return correct http status code" do
      let(:action) { get :index, county_id: county.id, town_id: town.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index, county_id: county.id, town_id: town.id }
    end

    it "should contain correct town's roads quantity" do
      get :index, county_id: county.id, town_id: town.id
      data = JSON.parse(response.body)["data"]
      expect(data.length).to eq(town.roads.length)
    end

    it "should find town's roads" do
      get :index, county_id: county.id, town_id: town.id
      data = JSON.parse(response.body)["data"]
      expect(data).to match_array(town.roads.select_api_fields.as_json)
    end
  end
end