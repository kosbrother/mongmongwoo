require 'rails_helper'

RSpec.describe Api::V3::ItemsController, type: :controller do
  describe "GET index" do
    context "with on shelf items" do
      let!(:category) { FactoryGirl.create(:category) }
      let!(:on_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category]) }
      let!(:off_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:off_shelf], categories: [category]) }

      it "should contain correct categoty's items quantity" do
        get :index, category_id: category.id
        json = JSON.parse(response.body)
        expect(json.length).to eq(Category.find(category.id).items.on_shelf.length)
      end

      it "should contain correct category's items data" do
        get :index, category_id: category.id
        json = JSON.parse(response.body)
        expect(json[0]['id']).to eq(Category.find(category.id).items.on_shelf[0].id)
        expect(json[0]['name']).to eq(Category.find(category.id).items.on_shelf[0].name)
        expect(json[0]['price']).to eq(Category.find(category.id).items.on_shelf[0].price)
        expect(json[0]['cover']['url']).to eq(Category.find(category.id).items.on_shelf[0].cover_url)
        expect(json[0]['specs']).to match_array(Category.find(category.id).items.on_shelf.as_json(include: { specs: { only: [:id, :style], include: { style_pic: { only: :url } } } })[0]['specs'])
      end
    end
  end

  describe "get #show" do
    let!(:category) { FactoryGirl.create(:category) }

    it 'does contain correct json' do
      item =  FactoryGirl.create(:item_with_specs_and_photos, categories: [category])
      get :show, category_id: category.id, id: item
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['name']).to eq(item.name)
      expect(json['price']).to eq(item.price)
      expect(json['cover']['url']).to eq(item.cover.url)
      expect(json['description']).to eq(item.description)
      expect(json['status']).to eq(item.status)
      expect(json['photos']).to match_array(JSON.parse(item.photos.as_json(only: [:image]).to_json))
      expect(json['specs']).to match_array(JSON.parse(item.specs.as_json(only: [:id, :style, :style_pic]).to_json))
    end
  end
end