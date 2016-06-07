require 'rails_helper'

RSpec.describe Api::V3::CountiesController, type: :controller do
  describe "Get index" do
    let!(:seven_store_county) { FactoryGirl.create(:seven_store_county) }
    let!(:non_seven_store_county) { FactoryGirl.create(:non_seven_store_county) }

    it_behaves_like "return correct http status code" do
      let(:action) { get :index }
    end

    it_behaves_like "return correct response format" do
      let(:action) { get :index }
    end

    context "with seven store type" do
      it "should contain correct county number" do
        get :index
        data = JSON.parse(response.body)["data"]
        expect(data.length).to eq(County.seven_stores.length)
      end

      it "should contain correct county data" do
        get :index
        data = JSON.parse(response.body)["data"]
        expect(data).to match_array(County.seven_stores.select_api_fields.as_json)
      end
    end
  end
end