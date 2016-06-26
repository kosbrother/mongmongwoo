require 'rails_helper'

RSpec.describe Api::V3::ShopInfosController, type: :controller do
  let!(:infos){FactoryGirl.create_list(:shop_info, 3)}

  describe "get #index" do
    it 'does return all the shop infos' do
      get :index
      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(3)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end
end