require 'spec_helper'

describe Api::V3::OrdersController, type: :controller do
  describe "post #create" do
    let!(:user) { FactoryGirl.create(:user_with_registration_device) }
    let!(:item) { FactoryGirl.create(:item_with_specs_and_photos) }
    let!(:store) { FactoryGirl.create(:store) }

    let!(:uid) { user.uid }
    let!(:items_price) { item.price }
    let!(:ship_fee) { 60 }
    let!(:total) { items_price + ship_fee }
    let!(:registration_id) { user.devices.first.registration_id }
    let!(:ship_name) { Faker::Name.name }
    let!(:ship_phone) { Faker::PhoneNumber.phone_number }
    let!(:ship_store_code) {store.store_code}
    let!(:ship_store_id) { store.id }
    let!(:ship_store_name) { store.name }
    let!(:ship_email) { Faker::Internet.email }
    let!(:product) { {id: item.id, name: item.name, spec_id: item.specs.first.id, style: item.specs.first.style, quantity: 1, price: item.price} }
    let!(:products) { [product] }

    it "does create correct order" do
      post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
           registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
           ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
           ship_email: ship_email, products: products
      order_id = ActiveSupport::JSON.decode(response.body)["data"]['id']
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

    it "return errors if missing order params" do
      post :create, registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
           ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
           ship_email: ship_email, products: products
      message = JSON.parse(response.body)["error"]["message"]
      expect(message).not_to be_nil
      expect(Order.all.size).to eq(0)
      expect(OrderInfo.all.size).to eq(0)
    end

    it "return errors if missing ship params" do
      post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
           registration_id: registration_id, products: products
      message = JSON.parse(response.body)["error"]["message"]
      expect(message).not_to be_nil
      expect(Order.all.size).to eq(0)
      expect(OrderInfo.all.size).to eq(0)
    end

    it "return errors if missing products params" do
      post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
           registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
           ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
           ship_email: ship_email
      message = JSON.parse(response.body)["error"]["message"]
      expect(message).not_to be_nil
      expect(Order.all.size).to eq(0)
      expect(OrderInfo.all.size).to eq(0)
    end
  end

  describe "get #show" do
    let!(:order) { FactoryGirl.create(:order_with_items) }
    before :each do
      get :show, id: order.id
    end
    context 'when order id provide' do
      it 'does generate correct order info' do
        result = JSON.parse(response.body)["data"]
        json = order.generate_result_order.to_json
        expect(result.to_json).to eq(json)
      end
    end
  end

  describe "get #user_owned_orders" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:orders) { create_list(:order_with_items, 3, user_id: user.id, uid: user.uid) }
    before :each do
      get :user_owned_orders, uid: user.uid, page: '1'
    end
    context 'when user id and page are provide' do
      it 'does generate correct order list' do
        result = JSON.parse(response.body)["data"]
        orders.reverse!
        expect(result.size).to eq(orders.size)
        expect(result[0]['id']).to eq(orders[0].id)
        expect(result[0]['user_id']).to eq(orders[0].user_id)
        expect(result[0]['uid']).to eq(orders[0].uid)
        expect(result[0]['total']).to eq(orders[0].total)
        expect(result[0]['status']).to eq(orders[0].status)
        expect(result[0]['created_on']).to eq(orders[0].created_on.to_s)
      end
    end
  end

  describe "get #by_email_phone" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:orders) { create_list(:order_with_items, 3, user_id: user.id, uid: user.uid) }
    let!(:email) { orders[0].info.ship_email }
    let!(:phone) { orders[0].info.ship_phone }
    before :each do
      get :by_email_phone, email: email, phone: phone
    end
    context 'when user email and phone are provided' do
      it 'does generate correct order list' do
        result = JSON.parse(response.body)["data"]
        orders.reverse!
        expect(result.size).to eq(orders.size)
        expect(result[0]['id']).to eq(orders[0].id)
        expect(result[0]['user_id']).to eq(orders[0].user_id)
        expect(result[0]['uid']).to eq(orders[0].uid)
        expect(result[0]['total']).to eq(orders[0].total)
        expect(result[0]['status']).to eq(orders[0].status)
        expect(result[0]['created_on']).to eq(orders[0].created_on.to_s)
      end
    end
  end
end