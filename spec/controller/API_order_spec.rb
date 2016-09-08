require 'spec_helper'

describe Api::V1::OrdersController, :type => :controller  do
  describe '#show' do
    let!(:item) { FactoryGirl.create(:item_with_specs_and_photos) }
    let!(:spec) { item.specs.first }
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    let!(:order) {  FactoryGirl.create(:order, items: [order_item]) }
    let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }

    before :each do
      get :show, id: order.id
    end

    context 'when send get request' do
      it 'should return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return JSON format' do
        expect(response.content_type).to eq("application/json")
      end

      it 'should contain correct order data' do
        json = JSON.parse(response.body)
        expect(json['id']).to eq(order.id)
      end

      it 'should contain correct info' do
        info = order.info
        json = JSON.parse(response.body)
        expect(json['info']['id']).to eq(info.id)
      end

      it 'should contain correct items number' do
        items = order.items
        json = JSON.parse(response.body)
        expect(json['items'].length).to eq(items.length)
      end
    end
  end
end