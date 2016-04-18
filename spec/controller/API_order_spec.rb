require 'spec_helper'

describe Api::V1::OrdersController, :type => :controller  do

  describe '#show'
  before :each do
    @order = FactoryGirl.create(:order_with_items)
    get :show, id: @order
    @json = JSON.parse(response.body)

  end

  context 'when send get request' do
    it 'should return status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'should return JSON format' do
      expect(response.content_type).to eq("application/json")
    end

    it 'should contain correct order data' do
      expect(@json['id']).to eq(@order.id)
    end

    it 'should contain correct info' do
      info = @order.info
      expect(@json['info']['id']).to eq(info.id)
    end

    it 'should contain correct items number' do
      items = @order.items
      expect(@json['items'].length).to eq(items.length)
    end

  end

end
