require 'rails_helper'

RSpec.describe Api::V3::CountiesController, type: :controller do
  let!(:seven_store_county) { FactoryGirl.create(:seven_store_county) }
  let!(:non_seven_store_county) { FactoryGirl.create(:non_seven_store_county) }

  describe "Get index" do
    it_behaves_like "return correct http status code" do
      let(:action) { get :index }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index }
    end

    context "with seven store type" do
      it "should contain correct county number" do
        get :index
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
      end

      it "should contain correct county data" do
        counties = [non_seven_store_county, seven_store_county]
        get :index
        json = JSON.parse(response.body)
        expect(json[0]['id']).to eq(counties[1].id)
        expect(json[0]['name']).to eq(counties[1].name)
      end
    end
  end
end