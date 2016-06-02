require 'rails_helper'

RSpec.describe Api::V3::CategoriesController, type: :controller do
  let(:all_items) { FactoryGirl.create(:category) }
  let(:new_items) { FactoryGirl.create(:category) }
  let!(:categories) { [all_items, new_items] }

  describe "GET index" do
    it "should contain correct category quantity" do
      get :index
      json = JSON.parse(response.body)
      expect(json.length).to eq(categories.length)
    end

    it "should contain correct category data" do
      get :index
      json = JSON.parse(response.body)
      expect(json[0]['id']).to eq(categories[0].id)
      expect(json[0]['name']).to eq(categories[0].name)
      expect(json[1]['id']).to eq(categories[1].id)
      expect(json[1]['name']).to eq(categories[1].name)
    end
  end

  describe "GET show" do
    context "with on shelf item" do
      let(:on_shelf_item) { FactoryGirl.create(:item, status: 0) }
      let(:off_shelf_item) { FactoryGirl.create(:item, status: 1) }

      before(:example) do
        all_items.items << on_shelf_item
        all_items.items << off_shelf_item
        get :show, id: all_items.id
      end

      it "should contain correct item quantity" do
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
      end

      it "should contain category's items" do
        json = JSON.parse(response.body)
        expect(json[0]['id']).to eq(all_items.items[0].id)
        expect(json[0]['name']).to eq(all_items.items[0].name)
        expect(json[0]['price']).to eq(all_items.items[0].price)
        expect(json[0]['position']).to eq(all_items.items[0].item_categories[0].position)
        expect(json[0]['cover']['url']).to eq(all_items.items[0].cover.url)
      end
    end

    context "with correct items quantity per page" do
      before(:example) do
        21.times do
          all_items.items << FactoryGirl.create(:item, status: 0)
        end

        get :show, id: all_items.id, page: 1
      end

      it "should contain twenty items for a category" do
        json = JSON.parse(response.body)
        expect(json.length).to eq(20)
      end
    end
  end
end