require 'spec_helper'
RSpec.describe Api::V3::SearchController, type: :controller do
  describe "get #search_items" do
    let!(:item) { FactoryGirl.create(:item, name: I18n.t('factory.item.name'), description: I18n.t('factory.item.description'))}
    before :each do
      Item.__elasticsearch__.create_index! index: Item.index_name
      Item.import
      sleep 1
    end
    after :each do
      Item.__elasticsearch__.client.indices.delete index: Item.index_name
    end
    context 'when  search term is included in item name' do
      it "does find the item", :elasticsearch do
        get :search_items, query: I18n.t('factory.term.name')
        result = JSON.parse(response.body)['data']
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(result.count).to eq(1)
        expect(result.first['id']).to eq(item.id)
        expect(result.first['name']).to eq(item.name)
        expect(result.first['cover']['url']).to eq(item.cover.url)
        expect(result.first['price']).to eq(item.price)
        expect(result.first['slug']).to eq(item.slug)
      end
    end
    context 'when  search term is included in item description' do
      it "does find the item", :elasticsearch do
        get :search_items, query: I18n.t('factory.term.description')
        result = JSON.parse(response.body)['data']
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(result.count).to eq(1)
        expect(result.first['id']).to eq(item.id)
        expect(result.first['name']).to eq(item.name)
        expect(result.first['cover']['url']).to eq(item.cover.url)
        expect(result.first['price']).to eq(item.price)
        expect(result.first['slug']).to eq(item.slug)
      end
    end
  end

  describe 'get #item_names' do
    let!(:items) {FactoryGirl.create_list(:item, 10)}
    it 'does show all the items name list' do
      get :item_names
      data = JSON.parse(response.body)['data']
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json')
      expect(data.count).to eq(10)
      expect(data[0]).to eq(items.first.name)
    end
  end
end