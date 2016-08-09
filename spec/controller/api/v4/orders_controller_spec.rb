require 'spec_helper'

describe Api::V4::OrdersController, type: :controller do
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
    let!(:product) { {product_id: item.id, name: item.name, spec_id: spec.id, style: spec.style, quantity: 1, price: item.price} }
    let!(:products) { [product] }

    context 'when item spec is on shelf and stock spec is sufficient' do
      let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 2) }
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
        message = response.body
        expect(message).to be_truthy
        expect(user.orders).to be_empty
      end

      it "return errors if missing ship params" do
        post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
             registration_id: registration_id, products: products
        message = response.body
        expect(message).to be_truthy
        expect(user.orders).to be_empty
      end

      it "return errors if missing products params" do
        post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
             registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
             ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
             ship_email: ship_email
        message = response.body
        expect(message).to be_truthy
        expect(user.orders).to be_empty
      end
    end

    context 'when stock spec is not sufficient' do
      let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 0) }
      it "does not create order" do
        post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
             registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
             ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
             ship_email: ship_email, products: products
        data = JSON.parse(response.body)["data"]["unable_to_buy"][0]
        expect(data["id"]).to eq(products[0][:product_id])
        expect(data["name"]).to eq(item.name)
        expect(data["spec"]["id"]).to eq(products[0][:spec_id])
        expect(data["spec"]["style"]).to eq(spec.style)
        expect(data["spec"]["style_pic"]["url"]).to eq(spec.style_pic.url)
        expect(data["spec"]["stock_amount"]).to eq(stock_spec.amount)
        expect(data["spec"]["status"]).to eq(spec.status)
        expect(data["quantity_to_buy"]).to eq(products[0][:quantity])
        expect(user.orders).to be_empty
      end
    end

    context 'when item spec is off shelf' do
      let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 2) }
      it "does not create order" do
        spec.update(status: ItemSpec.statuses[:off_shelf])
        post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
             registration_id: registration_id, ship_name: ship_name, ship_phone: ship_phone,
             ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
             ship_email: ship_email, products: products
        data = JSON.parse(response.body)["data"]["unable_to_buy"][0]
        expect(data["id"]).to eq(products[0][:product_id])
        expect(data["name"]).to eq(item.name)
        expect(data["spec"]["id"]).to eq(products[0][:spec_id])
        expect(data["spec"]["style"]).to eq(spec.style)
        expect(data["spec"]["style_pic"]["url"]).to eq(spec.style_pic.url)
        expect(data["spec"]["stock_amount"]).to eq(stock_spec.amount)
        expect(data["spec"]["status"]).to eq(spec.status)
        expect(data["quantity_to_buy"]).to eq(products[0][:quantity])
        expect(user.orders).to be_empty
      end
    end
  end
end