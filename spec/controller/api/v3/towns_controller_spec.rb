require 'rails_helper'

RSpec.describe Api::V3::TownsController, type: :controller do
  let!(:county) { FactoryGirl.create(:seven_store_county) }
  let!(:town) { FactoryGirl.create(:town, county: county) }

  describe "Get index" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :index, county_id: county.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index, county_id: county.id }
    end
    
    it "should find county's towns" do
      get :index, county_id: county.id
      json = JSON.parse(response.body)
      expect(json.length).to eq(county.towns.length)
      expect(json[0]['id']).to eq(county.towns[0].id)
      expect(json[0]['name']).to eq(county.towns[0].name)
    end
  end
end