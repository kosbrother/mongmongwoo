require 'spec_helper'

describe Api::V4::BannersController, type: :controller do
  describe "get #index" do
    let!(:category) { FactoryGirl.create(:category) }
    let!(:category_banner) { FactoryGirl.create(:banner, bannerable: category) }
    let!(:banners) { Banner.all }

    it 'does show all the banners data' do
      get :index
      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(banners.count)
      expect(data[0]["id"]).to eq(category_banner.id)
      expect(data[0]["bannerable_id"]).to eq(category_banner.bannerable_id)
      expect(data[0]["bannerable_type"]).to eq(category_banner.bannerable_type)
      expect(data[0]["title"]).to eq(category_banner.title)
      expect(data[0]["image"]["url"]).to eq(category_banner.image_url)
      expect(data[0]["app_index_url"]).to eq(category_banner.app_index_url)
    end
  end
end