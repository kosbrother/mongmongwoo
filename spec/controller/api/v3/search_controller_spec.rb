require 'spec_helper'
RSpec.describe Api::V3::SearchController, type: :controller do
  describe "get #search_items" do
    let!(:category) { FactoryGirl.create(:category) }
    let!(:on_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:on_shelf], categories: [category], name: I18n.t('factory.item.name'), description: I18n.t('factory.item.description')) }
    let!(:off_shelf_item) { FactoryGirl.create(:item_with_specs_and_photos, status: Item.statuses[:off_shelf], categories: [category], name: I18n.t('factory.item.name'), description: I18n.t('factory.item.description')) }
    before :each do
      Item.import
      Item.all.each{|i| i.save}
      sleep 1
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
        
        data = on_shelf_item.as_json(include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] } })
        data["specs"] = data["on_shelf_specs"]
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
      end
    end
  end

  describe 'get #item_names' do
    let!(:items) {FactoryGirl.create_list(:item, 10, status: Item.statuses["on_shelf"])}
    let!(:off_shelf_items) {FactoryGirl.create_list(:item, 5, status: Item.statuses["off_shelf"])}
    it 'does show all the items name list' do
      get :item_names
      data = JSON.parse(response.body)['data']
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json')
      expect(data.count).to eq(Item.on_shelf.size)
      expect(data[0]).to eq(items.first.name)
    end
  end

  describe 'get #hot_keywords' do
    it 'does show all hot keywords' do
      get :hot_keywords
      data = JSON.parse(response.body)['data']
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json')
      expect(data).to match_array(["雨鞋套","水杯水瓶","貼紙","韓版","便利貼","賀卡","筆袋","錢包","斜肩背包","髮圈","衛生棉包","收納袋","飾品","襪子","紋身貼"])
    end
  end
end