require 'spec_helper'
RSpec.describe Api::V4::SearchController, type: :controller do
  describe "get #search_items" do
    let!(:category) { FactoryGirl.create(:category) }
    let!(:on_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], name: I18n.t('factory.item.name'), description: I18n.t('factory.item.description')) }
    let!(:campaign_rule){ FactoryGirl.create(:exceed_quantity_percentage_off_campaign_rule, threshold: 3, discount_percentage: 0.9, valid_until: DateTime.now + 1.month  ) }
    let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule, discountable: on_shelf_item) }
    before :each do
      Item.import
      Item.all.each{|i| i.save}
      sleep 1
      on_shelf_item.reload
    end

    context 'when  search term is included in item name' do
      it "does find the item", :elasticsearch do
        get :search_items, query: I18n.t('factory.term.name')
        result = JSON.parse(response.body)['data']
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(result.count).to eq(1)
        expect(result.first['id']).to eq(on_shelf_item.id)
        expect(result.first['name']).to eq(on_shelf_item.name)
        expect(result.first['cover']['url']).to eq(on_shelf_item.cover.url)
        expect(result.first['price']).to eq(on_shelf_item.price)
        expect(result.first['slug']).to eq(on_shelf_item.slug)
        expect(result.first['discount_icon_url']).to eq(on_shelf_item.discount_icon_url)
        expect(result.first['final_price']).to eq(on_shelf_item.final_price)

        data = on_shelf_item.as_json(include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] } })
        data["specs"] = data.delete "on_shelf_specs"
        expect(result.first['specs']).to match_array(JSON.parse(data.to_json)['specs'])
      end
    end
    context 'when  search term is included in item description' do
      it "does find the item", :elasticsearch do
        get :search_items, query: I18n.t('factory.term.description')
        result = JSON.parse(response.body)['data']
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(result.count).to eq(1)
        expect(result.first['id']).to eq(on_shelf_item.id)
        expect(result.first['name']).to eq(on_shelf_item.name)
        expect(result.first['cover']['url']).to eq(on_shelf_item.cover.url)
        expect(result.first['price']).to eq(on_shelf_item.price)
        expect(result.first['slug']).to eq(on_shelf_item.slug)
        expect(result.first['discount_icon_url']).to eq(on_shelf_item.discount_icon_url)
        expect(result.first['final_price']).to eq(on_shelf_item.final_price)
      end
    end
  end
end