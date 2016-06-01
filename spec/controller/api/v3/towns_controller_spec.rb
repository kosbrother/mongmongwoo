require 'rails_helper'

RSpec.describe Api::V3::TownsController, type: :controller do
  let!(:county) { FactoryGirl.create(:county) }
  let!(:town) { FactoryGirl.create(:town, county: county) }

  describe "Get index" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :index, county_id: county.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index, county_id: county.id }
    end

    it "should return correct town data" do
      get :index, county_id: county.id
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq(town.name)
    end
  end
end