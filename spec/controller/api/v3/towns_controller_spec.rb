require 'rails_helper'

RSpec.describe Api::V3::TownsController, type: :controller do
  describe "Get index" do
    let!(:county) { FactoryGirl.create(:seven_store_county) }
    let!(:town) { FactoryGirl.create(:town, county: county) }

    it_behaves_like "return correct http status code" do
      let(:action) { get :index, county_id: county.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index, county_id: county.id }
    end

    it "should contain correct county's towns quantity" do
      get :index, county_id: county.id
      json = JSON.parse(response.body)
      expect(json.length).to eq(county.towns.length)
    end

    it "should contain county's towns data" do
      get :index, county_id: county.id
      json = JSON.parse(response.body)
      expect(json).to match_array(county.towns.select_api_fields.as_json)
    end
  end
end