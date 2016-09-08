require 'spec_helper'

describe Api::V4::OrdersController, type: :controller do
  let!(:item) { FactoryGirl.create(:item_with_specs_and_photos) }
  let!(:spec) { item.specs.first }
  let!(:store_delivery_type) { Order.ship_types.key(Order.ship_types["store_delivery"]) }
  let!(:home_delivery_type) { Order.ship_types.key(Order.ship_types["home_delivery"]) }

  describe "post#checkout" do
    let!(:user) { FactoryGirl.create(:user_with_registration_device) }
    let!(:items_price) { user_shopping_point_amount*5 }
    let!(:user_shopping_point_amount) { ShoppingPointManager.new(user).total_amount }
    context "when 10% of items price is lower than user_shopping_point_amount" do
      it "only return 10% of items price of shopping_point amount" do
        post :checkout, user_id: user.id, items_price: items_price
        data = JSON.parse(response.body)["data"]
        expect(data["shopping_point_amount"]).to eq((items_price * 0.1).round)
      end
    end

    context "when 10% of items price is higher than user_shopping_point_amount" do
      let!(:items_price) { user_shopping_point_amount*15 }
      it "only return total shopping_point amount" do
        post :checkout, user_id: user.id, items_price: items_price
        data = JSON.parse(response.body)["data"]
        expect(data["shopping_point_amount"]).to eq(user_shopping_point_amount)
      end
    end

    context "when user_id is annoymous user" do
      it "return 0 shopping_point" do
        post :checkout, user_id: User::ANONYMOUS, items_price: items_price
        data = JSON.parse(response.body)["data"]
        expect(data["shopping_point_amount"]).to eq(0)
      end
    end
  end

  describe "post #create" do
    let!(:user) { FactoryGirl.create(:user_with_registration_device) }
    let!(:store) { FactoryGirl.create(:store) }
    let!(:uid) { user.uid }
    let!(:items_price) { item.price }
    let!(:ship_fee) { 60 }
    let!(:total) { items_price + ship_fee }
    let!(:registration_id) { user.devices.first.registration_id }
    let!(:ship_address) { Faker::Address.street_address }
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
               registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone, ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
               ship_email: ship_email, products: products
          order_id = JSON.parse(response.body)["data"]['id']
          order = Order.find(order_id)
          expect(order.uid).to eq(uid)
          expect(order.items_price).to eq(items_price)
          expect(order.ship_fee).to eq(ship_fee)
          expect(order.total).to eq(total)
          expect(order.device_registration_id).to eq(DeviceRegistration.find_by(registration_id: registration_id).id)
          expect(order.ship_type).to eq(store_delivery_type)
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
               registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
               ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
               ship_email: ship_email, products: products
          order_id = JSON.parse(response.body)["data"]['id']
          order = Order.find(order_id)
          expect(order.items_price).to eq(items_price)
          expect(order.ship_fee).to eq(ship_fee)
          expect(order.total).to eq(total)
          expect(order.device_registration_id).to eq(DeviceRegistration.find_by(registration_id: registration_id).id)
          expect(order.ship_type).to eq(store_delivery_type)
          expect(order.info.ship_name).to eq(ship_name)
          expect(order.info.ship_phone).to eq(ship_phone)
          expect(order.info.ship_store_code).to eq(ship_store_code)
          expect(order.info.ship_email).to eq(ship_email)
          expect(order.items.size).to eq(products.size)
          expect(order.items[0].item_name).to eq(product[:name])
        end
      end

      context "when shopping point is used" do
        let!(:shopping_point_campaign) { FactoryGirl.create(:shopping_point_campaign) }
        let!(:shopping_point) { FactoryGirl.create(:campaign_point, user: user, amount: shopping_point_campaign.amount, shopping_point_campaign: shopping_point_campaign) }
        let!(:spend_amount) { user.shopping_points.valid.sum(:amount) }
        it "does spend user's shopping point" do
          post :create, email: user.email, items_price: items_price, ship_fee: ship_fee, total: total,
               registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
               ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
               ship_email: ship_email, products: products, shopping_points_amount: spend_amount
          order_id = JSON.parse(response.body)["data"]["id"]

          user.shopping_points.each do |shopping_point|
            expect(shopping_point.shopping_point_records.last.order_id).to eq(order_id)
          end
          expect(user.shopping_points.valid.sum(:amount)).to eq(0)
        end
      end

      context "when ship type is home delivery" do
        it "does create correct order" do
          post :create, email: user.email, items_price: items_price, ship_fee: ship_fee, total: total,
               registration_id: registration_id, ship_type: home_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
               ship_address: ship_address, ship_email: ship_email, products: products
          order_id = JSON.parse(response.body)["data"]['id']
          order = Order.find(order_id)
          expect(order.items_price).to eq(items_price)
          expect(order.ship_fee).to eq(ship_fee)
          expect(order.total).to eq(total)
          expect(order.device_registration_id).to eq(DeviceRegistration.find_by(registration_id: registration_id).id)
          expect(order.ship_type).to eq(home_delivery_type)
          expect(order.info.ship_email).to eq(ship_email)
          expect(order.info.ship_address).to eq(ship_address)
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
             registration_id: registration_id, ship_type: store_delivery_type, products: products
        message = response.body
        expect(message).to be_truthy
        expect(user.orders).to be_empty
      end

      it "return errors if missing products params" do
        post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
             registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
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
             registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
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
             registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
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

  describe "get #show" do
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }

    context 'when order is store delivery' do
      let!(:store_delevery_order) { FactoryGirl.create(:order, items: [order_item], ship_type: store_delivery_type) }
      let!(:store_delivery_order_info) { FactoryGirl.create(:store_delivery_order_info, order: store_delevery_order) }

      it 'does generate correct order info' do
        get :show, id: store_delevery_order.id
        result = JSON.parse(response.body)["data"]
        order = Order.find(store_delevery_order.id)
        json = order.generate_result_order.to_json
        expect(result.to_json).to eq(json)
      end
    end

    context 'when order is home delivery' do
      let!(:home_delivery_order) { FactoryGirl.create(:order, items: [order_item], ship_type: home_delivery_type) }
      let!(:home_delivery_order_info) { FactoryGirl.create(:home_delivery_order_info, order: home_delivery_order) }

      it 'does generate correct order info' do
        get :show, id: home_delivery_order.id
        result = JSON.parse(response.body)["data"]
        order = Order.find(home_delivery_order.id)
        json = order.generate_result_order.to_json
        expect(result.to_json).to eq(json)
      end
    end
  end
end