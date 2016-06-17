require 'rails_helper'

RSpec.describe Api::V3::ItemsController, type: :controller do
  describe "GET index" do
    context "with on shelf items" do
      let!(:category) { FactoryGirl.create(:category) }
      let!(:on_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category]) }
      let!(:off_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:off_shelf], categories: [category]) }

      it "should contain correct categoty's items quantity" do
        get :index, category_id: category.id
        data = JSON.parse(response.body)["data"]
        expect(data.length).to eq(Category.find(category.id).items.on_shelf.length)
      end

      it "should contain correct category's items data" do
        get :index, category_id: category.id
        data = JSON.parse(response.body)["data"]
        expect(data[0]['id']).to eq(Category.find(category.id).items.on_shelf[0].id)
        expect(data[0]['name']).to eq(Category.find(category.id).items.on_shelf[0].name)
        expect(data[0]['price']).to eq(Category.find(category.id).items.on_shelf[0].price)
        expect(data[0]['slug']).to eq(Category.find(category.id).items.on_shelf[0].slug)
        expect(data[0]['cover']['url']).to eq(Category.find(category.id).items.on_shelf[0].cover_url)
        expect(data[0]['specs']).to match_array(JSON.parse(Category.find(category.id).items.on_shelf.to_json(include: { specs: { only: [:id, :style, :style_pic] } }))[0]['specs'])
      end
    end
    context "with sort param" do
      let!(:category) { FactoryGirl.create(:category) }
      let!(:on_shelf_item_1) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], price: 50, created_at: Time.now) }
      let!(:on_shelf_item_2) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], price: 100, created_at: Time.now + 1) }
      let!(:on_shelf_item_3) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], price: 70, created_at: Time.now + 2) }

      it "should order by price desc when with sort param price_desc" do
        get :index, category_id: category.id, sort: "price_desc"
        data = JSON.parse(response.body)["data"]
        expect(data[0]['id']).to eq(on_shelf_item_2.id)
        expect(data[1]['id']).to eq(on_shelf_item_3.id)
        expect(data[2]['id']).to eq(on_shelf_item_1.id)
      end

      it "should order by price asc when with sort param price_asc" do
        get :index, category_id: category.id, sort: "price_asc"
        data = JSON.parse(response.body)["data"]
        expect(data[0]['id']).to eq(on_shelf_item_1.id)
        expect(data[1]['id']).to eq(on_shelf_item_3.id)
        expect(data[2]['id']).to eq(on_shelf_item_2.id)
      end

      it "should order by priority when with sort param popular" do
        on_shelf_item_1.item_categories[0].update_attribute(:position, 3)
        on_shelf_item_2.item_categories[0].update_attribute(:position, 1)
        on_shelf_item_3.item_categories[0].update_attribute(:position, 2)

        get :index, category_id: category.id, sort: "popular"
        data = JSON.parse(response.body)["data"]
        expect(data[0]['id']).to eq(on_shelf_item_2.id)
        expect(data[1]['id']).to eq(on_shelf_item_3.id)
        expect(data[2]['id']).to eq(on_shelf_item_1.id)
      end

      it "should order by create date when with sort param date" do
        get :index, category_id: category.id, sort: "date"
        data = JSON.parse(response.body)["data"]
        expect(data[0]['id']).to eq(on_shelf_item_3.id)
        expect(data[1]['id']).to eq(on_shelf_item_2.id)
        expect(data[2]['id']).to eq(on_shelf_item_1.id)
      end
    end
  end

  describe "get #show" do
    let!(:category) { FactoryGirl.create(:category) }

    it 'does contain correct data' do
      item =  FactoryGirl.create(:item_with_specs_and_photos, categories: [category])
      get :show, category_id: category.id, id: item
      data = JSON.parse(response.body)["data"]
      expect(data['name']).to eq(item.name)
      expect(data['price']).to eq(item.price)
      expect(data['cover']['url']).to eq(item.cover.url)
      expect(data['description']).to eq(item.description)
      expect(data['status']).to eq(item.status)
      expect(data['slug']).to eq(item.slug)
      expect(data['photos']).to match_array(JSON.parse(item.photos.as_json(only: [:image]).to_json))
      expect(data['specs']).to match_array(JSON.parse(item.specs.as_json(only: [:id, :style, :style_pic]).to_json))
    end
  end
end