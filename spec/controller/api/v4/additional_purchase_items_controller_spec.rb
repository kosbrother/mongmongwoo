require 'spec_helper'

describe Api::V4::AdditionalPurchaseItemsController, type: :controller do
  describe "get#index" do
    let!(:all_category) { FactoryGirl.create(:category, id: 10, name: "所有商品") }
    let!(:new_category) { FactoryGirl.create(:category, id: 11, name: "新品上架") }
    let!(:some_category) { FactoryGirl.create(:category, id: 16) }
    let!(:item) { FactoryGirl.create(:item, status: Item.statuses[:on_shelf], price: 299, categories: [some_category, all_category, new_category]) }
    let!(:additional_puechase_item) { FactoryGirl.create(:additional_purchase_item, item: item, price: 159) }
    let!(:price_reduction) { item.price - additional_puechase_item.price }
    let!(:additional_purchase_items_size) { AdditionalPurchaseItem.count }

    it "does show all the additional purchase items data" do
      get :index
      data = JSON.parse(response.body)["data"]
      expect(data.size).to eq(additional_purchase_items_size)
      expect(data[0]["id"]).to eq(additional_puechase_item.id)
      expect(data[0]["price"]).to eq(additional_puechase_item.price)
      expect(data[0]["price_reduction"]).to eq(price_reduction)
      expect(data[0]["item"]["id"]).to eq(item.id)
      expect(data[0]["item"]["name"]).to eq(item.name)
      expect(data[0]["item"]["price"]).to eq(item.price)
      expect(data[0]["item"]["cover"]["url"]).to eq(item.cover.url)
      expect(data[0]["category_id"]).to eq(some_category.id)
    end
  end
end