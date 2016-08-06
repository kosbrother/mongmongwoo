require 'spec_helper'

RSpec.describe Api::V3::WishListsController, :type => :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:item) { FactoryGirl.create(:item_with_specs_and_photos) }
  let!(:spec) { item.specs.first }
  let!(:spec_2) { item.specs.second }
  let!(:stock_spec) { FactoryGirl.create(:stock_spec, item_spec_id: spec.id, item_id: item.id, amount: 10) }

  describe "get#index" do
    let!(:wish_list) { FactoryGirl.create(:wish_list, user_id: user.id, item_id: item.id, item_spec_id: spec.id ) }

    it 'does show all the wish lists' do
      get :index, user_id: user.id
      data = JSON.parse(response.body)["data"]

      expect(data[0]['id']).to eq (user.wish_lists.first.id)
      expect(data[0]['item']['id']).to eq(item.id)
      expect(data[0]['item']['name']).to eq(item.name)
      expect(data[0]['item']['price']).to eq(item.price)
      expect(data[0]['item']['final_price']).to eq(item.final_price)
      expect(data[0]['item_spec']['id']).to eq(spec.id)
      expect(data[0]['item_spec']['style']).to eq(spec.style)
      expect(data[0]['item_spec']['style_pic']['url']).to eq(spec.style_pic.url)
      expect(data[0]['item_spec']['stock_amount']).to eq(10)
    end
  end

  describe "post#create" do
    context "when wish list params are provided" do
      it "does create wish lists" do
        post :create, user_id: user.id, wish_lists: [{item_id: item.id, item_spec_id: spec.id}, {item_id: item.id, item_spec_id: spec_2.id}]
        wish_lists = user.wish_lists
        message = JSON.parse(response.body)['data']

        expect(message).to eq("success")
        expect(wish_lists).to be_present
        expect(wish_lists.first.item_spec_id).to eq(spec.id)
      end
    end

    context "when same wish lists exist" do
      let!(:wish_list) { FactoryGirl.create(:wish_list, user_id: user.id, item_id: item.id, item_spec_id: spec.id ) }
      let!(:wish_list_2) { FactoryGirl.create(:wish_list, user_id: user.id, item_id: item.id, item_spec_id: spec_2.id ) }

      it "does not create new wish_list" do
        before_size = user.wish_lists.size
        post :create, user_id: user.id, wish_lists: [{item_id: item.id, item_spec_id: spec.id}, {item_id: item.id, item_spec_id: spec_2.id}]
        message = JSON.parse(response.body)['data']

        expect(message).to eq("success")
        expect(user.wish_lists.size).to eq(before_size)
      end
    end
  end

  describe "delete#destroy" do
    let!(:wish_list) { FactoryGirl.create(:wish_list, user_id: user.id, item_id: item.id, item_spec_id: spec.id ) }

    it "does delete existed wish list" do
      delete :destroy, user_id: user.id, item_spec_id: spec.id
      message = JSON.parse(response.body)['data']

      expect(message).to eq("success")
      expect(user.wish_lists).to be_empty
    end
  end
end