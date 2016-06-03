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
        expect(json[0]['cover']['url']).to eq(Category.find(category.id).items.on_shelf[0].cover_url.as_json)
        expect(json[0]['description']).to eq(Category.find(category.id).items.on_shelf[0].description)
        expect(json[0]['status']).to eq(Category.find(category.id).items.on_shelf[0].status)
        expect(json[0]['specs']).to match_array(Category.find(category.id).items.on_shelf.as_json(include: { specs: { only: [:id, :style], include: { style_pic: { only: :url } } } })[0]['specs'])
      end
    end
  end

  describe "get #show" do
    it 'does contain correct json' do
      item =  FactoryGirl.create(:item_with_specs_and_photos)
      get :show, id: item
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['name']).to eq(item.name)
      expect(json['price']).to eq(item.price)
      expect(json['cover']).to eq(item.cover.url)
      expect(json['description']).to eq(item.description)
      expect(json['status']).to eq(item.status)
      expect(json['photos']).to match_array(item.photos.collect { |photo| {"image_url" => photo.image.url} })
      expect(json['specs']).to match_array(item.specs.on_shelf.collect { |spec| {"id" => spec.id, "style" => spec.style,
                                                                                 "style_pic" => spec.style_pic.url}})
    end
  end
end