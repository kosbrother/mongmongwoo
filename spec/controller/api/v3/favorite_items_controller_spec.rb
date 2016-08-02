require 'spec_helper'

RSpec.describe Api::V3::FavoriteItemsController, :type => :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:item) { FactoryGirl.create(:item) }
  let!(:item_2) { FactoryGirl.create(:item) }

  describe "get#index" do
    let!(:favorite_item) { FactoryGirl.create(:favorite_item, user_id: user.id, item_id: item.id) }

    it 'does show all the favorite items' do
      get :index, user_id: user.id
      data = JSON.parse(response.body)["data"]

      expect(data[0]['id']).to eq (user.favorite_items.first.id)
      expect(data[0]['item']['id']).to eq(item.id)
      expect(data[0]['item']['name']).to eq(item.name)
      expect(data[0]['item']['final_price']).to eq(item.final_price)
    end
  end

  describe "post#create" do
    context "when many favorite items are provided" do
      it "does create many favorite items" do
        post :create, user_id: user.id, favorite_items: [{item_id: item.id},{item_id: item_2.id}]
        favorite_items = user.favorite_items
        message = JSON.parse(response.body)['data']

        expect(message).to eq("success")
        expect(favorite_items).to be_present
        expect(favorite_items.first.item_id).to eq(item.id)
      end
    end

    context "when same favorite items exist" do
      let!(:favorite_item) { FactoryGirl.create(:favorite_item, user_id: user.id, item_id: item.id) }
      let!(:favorite_item_2) { FactoryGirl.create(:favorite_item, user_id: user.id, item_id: item_2.id) }

      it "does not create new favorite item" do
        before_size = user.favorite_items.size
        post :create, user_id: user.id, favorite_items: [{item_id: item.id},{item_id: item_2.id}]
        message = JSON.parse(response.body)['data']

        expect(message).to eq("success")
        expect(user.favorite_items.size).to eq(before_size)
      end
    end
  end

  describe "delete#destroy" do
    let!(:favorite_item) { FactoryGirl.create(:favorite_item, user_id: user.id, item_id: item.id) }

    it "does delete existed favorite item" do
      delete :destroy, user_id: user.id, item_id: item.id
      message = JSON.parse(response.body)['data']

      expect(message).to eq("success")
      expect(user.favorite_items).to be_empty
    end
  end
end