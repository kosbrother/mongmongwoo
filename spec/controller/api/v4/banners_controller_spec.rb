require 'spec_helper'

describe Api::V4::BannersController, type: :controller do
  include Admin::BannersHelper

  describe "get #index" do
    let!(:category) { FactoryGirl.create(:category) }
    let!(:category_banner) { FactoryGirl.create(:banner, bannerable: category) }
    let!(:banners) { Banner.recent }

    it 'does show all the banners data' do
      get :index
      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(banners.count)
      expect(data[0]["id"]).to eq(banners[0].id)
      expect(data[0]["bannerable_id"]).to eq(banners[0].bannerable_id)
      expect(data[0]["bannerable_type"]).to eq(banners[0].bannerable_type)
      expect(data[0]["title"]).to eq(banners[0].title)
      expect(data[0]["image"]["url"]).to eq(banners[0].image_url)
      expect(data[0]["url"]).to eq(bannerable_url(banners[0]))
    end
  end
end