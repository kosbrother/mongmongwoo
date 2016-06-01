require 'rails_helper'

RSpec.describe Api::V3::CountiesController, type: :controller do
  let!(:county) { FactoryGirl.create(:county) }
  let!(:town) { FactoryGirl.create(:town, county: county) }

  describe "Get index" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :index }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index }
    end

    it "should return correct county data" do
      get :index
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq(county.name)
    end
  end

  describe "Get show" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :show, id: county.id }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :show, id: county.id }
    end

    it "should return correct town data" do
      get :show, id: county.id
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq(town.name)
    end
  end
end