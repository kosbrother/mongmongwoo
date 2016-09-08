require 'spec_helper'

describe Api::V3::OrdersController, type: :controller do
  let!(:item) { FactoryGirl.create(:item_with_specs_and_photos) }
  let!(:spec) { item.specs.first }

  describe "post #create" do
    let!(:user) { FactoryGirl.create(:user_with_registration_device) }
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
    let!(:products) { [product] }
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 2) }
    let!(:product) { {product_id: item.id, name: item.name, spec_id: spec.id, style: spec.style, quantity: 1, price: item.price} }
    context 'when  uid is provided' do
      it "does create correct order" do
        post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
             registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
             ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
             ship_email: ship_email, products: products
        order_id = JSON.parse(response.body)["data"]['id']
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
    end

    context 'when  email is provided' do
      it "does create correct order" do
        post :create, email: user.email, items_price: items_price, ship_fee: ship_fee, total: total,
             registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
             ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
             ship_email: ship_email, products: products
        order_id = JSON.parse(response.body)["data"]['id']
        order = Order.find(order_id)
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
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    let!(:order) { FactoryGirl.create(:order, items: [order_item]) }
    let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
    before :each do
      get :show, id: order.id
    end
    context 'when order id provide' do
      it 'does generate correct order info' do
        result = JSON.parse(response.body)["data"]
        the_order = Order.find(order.id)
        json = the_order.generate_result_order.to_json
        expect(result.to_json).to eq(json)
      end
    end
  end

  describe "get #user_owned_orders" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    let!(:order) { FactoryGirl.create(:order, user: user, uid: user.uid, items: [order_item]) }
    let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
    let!(:orders) { [order] }
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
        expect(result[0]['created_on']).to eq(orders[0].created_at.strftime("%Y-%m-%d"))
      end
    end
  end

  describe "get #by_email_phone" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    let!(:order) { FactoryGirl.create(:order, user: user, uid: user.uid, items: [order_item]) }
    let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
    let!(:orders) { [order] }
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
        expect(result[0]['created_on']).to eq(orders[0].created_at.strftime("%Y-%m-%d"))
      end
    end
  end

  describe "get #by_user_email" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    let!(:order) { FactoryGirl.create(:order, user: user, uid: user.uid, items: [order_item]) }
    let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
    let!(:orders) { [order] }
    let!(:email) { user.email }
    before :each do
      get :by_user_email, email: email
    end
    context 'when user email is provided' do
      it 'does generate correct order list' do
        result = JSON.parse(response.body)["data"]
        orders = Order.recent
        expect(result.size).to eq(orders.size)
        expect(result[0]['id']).to eq(orders[0].id)
        expect(result[0]['user_id']).to eq(orders[0].user_id)
        expect(result[0]['uid']).to eq(orders[0].uid)
        expect(result[0]['total']).to eq(orders[0].total)
        expect(result[0]['status']).to eq(orders[0].status)
        expect(result[0]['created_on']).to eq(orders[0].created_at.strftime("%Y-%m-%d"))
      end
    end
  end

  describe "patch #cancel" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    context "when order status is new" do
      let!(:order) { FactoryGirl.create(:order, user_id: user.id, status: Order.statuses["新訂單"], items: [order_item]) }
      let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }

      it "does update the user order to cancel" do
        patch :cancel, user_id: user.id, id: order.id
        result = JSON.parse(response.body)["data"]
        order = user.orders.first

        expect(result).to eq(I18n.t('controller.success.message.cancel_order'))
        expect(order.status).to eq("訂單取消")
      end
    end

    context "when order status is processing" do
      let!(:order) { FactoryGirl.create(:order, user_id: user.id, status: Order.statuses["處理中"], items: [order_item]) }
      let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }

      it "does update the user order to cancel" do
        patch :cancel, user_id: user.id, id: order.id
        result = JSON.parse(response.body)["data"]
        order = user.orders.first

        expect(result).to eq(I18n.t('controller.success.message.cancel_order'))
        expect(order.status).to eq("訂單取消")
      end
    end

    context "when order status is shipping" do
      let!(:order) { FactoryGirl.create(:order, user_id: user.id, status: Order.statuses["配送中"], items: [order_item]) }
      let!(:order_info) { FactoryGirl.create(:store_delivery_order_info, order: order) }

      it "does not update the user order to cancel" do
        patch :cancel, user_id: user.id, id: order.id
        message = response.body
        order = user.orders.first

        expect(message).to eq(I18n.t('controller.error.message.can_not_cancel_order'))
        expect(order.status).to eq("配送中")
      end
    end
  end
end