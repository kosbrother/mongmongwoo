require 'spec_helper'

describe Api::V3::OrdersController, type: :controller do
  describe "post #create" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:item) { FactoryGirl.create(:item) }
    let!(:item_spec) { FactoryGirl.create(:item_spec) }
    let!(:store) { FactoryGirl.create(:store) }

    let!(:uid) { user.uid }
    let!(:items_price) { item.price }
    let!(:ship_fee) { 60 }
    let!(:total) { items_price + ship_fee }
    let!(:registration_id) { Faker::Lorem.characters }
    let!(:ship_name) { Faker::Name.name }
    let!(:ship_phone) { Faker::PhoneNumber.phone_number }
    let!(:ship_store_code) {store.store_code}
    let!(:ship_store_id) { store.id }
    let!(:ship_store_name) { store.name }
    let!(:ship_email) { Faker::Internet.email }
    let!(:product) { {name: item.name, style: item_spec.style, quantity: 1, price: item.price} }
    let!(:products) { [product] }

    before :each do
      post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
           registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
           ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
           ship_email: ship_email, products: products
    end
    it "does create correct order" do
      order_id = ActiveSupport::JSON.decode(response.body)['id']
      order = Order.find(order_id)
      expect(order.uid).to eq(uid)
      expect(order.items_price).to eq(items_price)
      expect(order.ship_fee).to eq(ship_fee)
      expect(order.total).to eq(total)
      expect(order.device_registration_id).to eq(DeviceRegistration.find_by(registration_id: registration_id).id)
      expect(order.info.ship_name).to eq(ship_name)
      expect(order.info.ship_phone).to eq(ship_phone)
      expect(order.info.ship_store_code).to eq(ship_store_code)
      expect(order.info.ship_email).to eq(ship_email)
      expect(order.items.size).to eq(products.size)
      expect(order.items[0].item_name).to eq(product[:name])
    end
    context 'when registration id exist' do
      rg = FactoryGirl.create(:device_registration)
      let!(:registration_id) { rg.registration_id }
      # let!(:registration_id)
      it 'does not create new device_registration' do
        expect(DeviceRegistration.all.size).to eq(1)
      end
    end
  end

  describe "get #show" do
    let!(:order) { FactoryGirl.create(:order_with_items) }
    before :each do
      get :show, id: order.id
    end
    context 'when order id provide' do
      it 'should generate correct order info' do
        result = response.body
        json = order.generate_result_order.to_json
        expect(result).to eq(json)
      end
    end
  end
end