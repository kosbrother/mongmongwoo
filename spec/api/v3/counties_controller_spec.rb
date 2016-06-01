require 'rails_helper'

RSpec.describe Api::V3::CountiesController, type: :controller do
  let!(:county) { FactoryGirl.create(:county) }
  let!(:town) { FactoryGirl.create(:town, county: county) }

  describe "Get index" do
    it "should return status code 200" do
      get :index
      expect(response).to have_http_status(200)
    end

    it "should return JSON format" do
      get :index
      expect(response.content_type).to eq("application/json")
    end

    it "should return correct county data" do
      get :index
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq(county.name)
    end

    describe "Get show" do
      it "should return status code 200" do
        get :show, id: county.id
        expect(response).to have_http_status(200)
      end

      it "should return JSON format" do
        get :show, id: county.id
        expect(response.content_type).to eq("application/json")
      end

      it "should return correct town data" do
        get :show, id: county.id
        json = JSON.parse(response.body)
        expect(json[0]['name']).to eq(town.name)
      end
    end
  end
end