require 'rails_helper'

RSpec.describe Api::V3::RoadsController, type: :controller do
  let!(:county) { FactoryGirl.create(:county) }
  let!(:town) { FactoryGirl.create(:town, county: county) }
  let!(:road) { FactoryGirl.create(:road, town: town) }

  describe "Get index" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :index, county_id: county.id, town_id: town.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index, county_id: county.id, town_id: town.id }
    end

    it "should return correct road data" do
      get :index, county_id: county.id, town_id: town.id
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq(road.name)
    end
  end
end