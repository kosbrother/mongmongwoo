require 'rails_helper'

RSpec.describe Api::V4::ItemsController, type: :controller do
  describe "GET index" do
    context "with on shelf items" do
      let!(:category) { FactoryGirl.create(:category) }
      let!(:on_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category]) }
      let!(:off_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:off_shelf], categories: [category]) }

      it "should contain correct categoty's items quantity" do
        get :index, category_id: category.id
        data = JSON.parse(response.body)['data']
        expect(data.length).to eq(1)
      end

      it "should contain correct category's items data" do
        get :index, category_id: category.id
        data = JSON.parse(response.body)["data"]
        expect(data[0]['id']).to eq(on_shelf_item.id)
        expect(data[0]['name']).to eq(on_shelf_item.name)
        expect(data[0]['price']).to eq(on_shelf_item.price)
        expect(data[0]['slug']).to eq(on_shelf_item.slug)
        expect(data[0]['cover']['url']).to eq(on_shelf_item.cover_url)
        expect(data[0]['discount_icon']).to eq(on_shelf_item.discount_icon.as_json)

        datas = Category.find(category.id).items.on_shelf.as_json(include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] } })
        datas.each{|data| data["specs"] = data.delete "on_shelf_specs"}

        expect(data[0]['specs']).to match_array(JSON.parse(datas.to_json)[0]['specs'])
      end
    end

    context "when item has campaign" do
      let!(:category) { FactoryGirl.create(:category) }
      let!(:item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category]) }
      let!(:campaign_rule){ FactoryGirl.create(:exceed_quantity_percentage_off_campaign_rule, threshold: 3, discount_percentage: 0.9) }
      let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule, discountable: item) }
      it "does return item discount_icon url" do
        get :index, category_id: category.id
        data = JSON.parse(response.body)["data"]
        expect(data[0]['discount_icon']).to eq(item.discount_icon.as_json)
      end
    end

    context "with sort param" do
      let!(:category) { FactoryGirl.create(:category) }
      let!(:on_shelf_item_1) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], price: 50, created_at: Time.current) }
      let!(:on_shelf_item_2) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], price: 100, created_at: Time.current + 1) }
      let!(:on_shelf_item_3) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], price: 70, created_at: Time.current + 2) }

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
end