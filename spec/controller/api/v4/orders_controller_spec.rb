require 'spec_helper'

describe Api::V4::OrdersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user_with_registration_device) }
  let!(:user_shopping_point_amount) { ShoppingPointManager.new(user).total_amount }
  let!(:item) { FactoryGirl.create(:item_with_specs_and_photos, price: 100, special_price: nil) }
  let!(:spec) { item.specs.first }
  let!(:quantity) { 5 }
  let!(:items_price){ quantity*item.price }
  let!(:store_delivery_type) { "store_delivery" }
  let!(:home_delivery_type) { "home_delivery" }
  let!(:home_delivery_by_credit_card_type) { "home_delivery_by_credit_card" }

  describe "post#checkout" do
    let!(:products) { [{id: item.id, item_spec_id: spec.id, quantity: quantity}] }

    context "when user has shopping points" do
      it "does show aviailable shopping point amount" do
        post :checkout, user_id: user.id, products: products, is_spend_shopping_point: false
        data = JSON.parse(response.body)["data"]

        expect(data['order_price']).to have_key('shopping_point')
        expect(data['order_price']['shopping_point']['spendable_amount']).to eq(user_shopping_point_amount)
        expect(data['order_price']['shopping_point']['used_amount']).to eq(0)
        expect(data['order_price']['shopping_point']['reduced_items_price']).to eq(items_price)
      end
    end

    context "when missing products params" do
      it "return errors if missing products params" do
        post :checkout, user_id: user.id, is_spend_shopping_point: false
        message = response.body
        expect(message).to be_truthy
      end
    end

    context "when products params is provided" do
      it "does calculate correct data for checkout" do
        post :checkout, user_id: user.id, products: products, is_spend_shopping_point: false
        data = JSON.parse(response.body)["data"]

        expect(data['products'].size).to eq(products.size)
        expect(data['products'][0]['id'].to_i).to eq(item.id)
        expect(data['products'][0]['item_spec_id'].to_i).to eq(spec.id)
        expect(data['products'][0]['quantity'].to_i).to eq(quantity)
        expect(data['products'][0]['price']).to eq(item.price)
        expect(data['products'][0]['final_price']).to eq(item.price)
        expect(data['products'][0]['subtotal']).to eq(items_price)
        expect(data['products'][0]).to have_key('campaign')

        expect(data).to have_key('order_price')
        expect(data['order_price']['origin_items_price']).to eq(items_price)
        expect(data['order_price']['shopping_point']['spendable_amount']).to eq(user_shopping_point_amount)
        expect(data['order_price']['shopping_point']['used_amount']).to eq(0)
        expect(data['order_price']['shopping_point']['reduced_items_price']).to eq(items_price)
        expect(data['order_price']).to have_key('campaigns')
        expect(data['order_price']['obtain_shopping_point_amount']).to eq(0)
        expect(data['order_price']).to have_key('shopping_point_campaigns')
        expect(data['order_price']['ship_fee']).to eq(PriceManager.count_ship_fee(items_price))
        expect(data['order_price']['ship_campaign']).to eq(PriceManager.get_free_ship_campaign(items_price).as_json)
        expect(data['order_price']['total']).to eq(items_price + PriceManager.count_ship_fee(items_price))
      end
    end

    context "when product have asigned campaign and could be discounted" do
      let!(:campaign_rule){ FactoryGirl.create(:exceed_quantity_percentage_off_campaign_rule, threshold: 3, discount_percentage: 0.9) }
      let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule, discountable: item) }
      it "does apply discount and return product campaign info" do
        post :checkout, user_id: user.id, products: products, is_spend_shopping_point: false
        data = JSON.parse(response.body)["data"]

        expect(data['products'][0]['price']).to eq(item.price)
        expect(data['products'][0]['final_price']).to eq((item.price * 0.9).round)
        expect(data['products'][0]['subtotal']).to eq((item.price * 0.9).round*quantity)
        expect(data['products'][0]['campaign']['is_applied']).to be_truthy
        expect(data['products'][0]['campaign']['title']).to eq(campaign_rule.title)
        expect(data['products'][0]['campaign']['left_to_apply']).to eq(0)
      end
    end

    context "when order have asigned campaign and could be discount" do
      let!(:campaign_rule){ FactoryGirl.create(:exceed_amount_money_off_campaign_rule, threshold: 500, discount_money: 100) }
      let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule) }
      it "does apply discount and return campaign info" do
        post :checkout, user_id: user.id, products: products, is_spend_shopping_point: false
        data = JSON.parse(response.body)["data"]

        expect(data['order_price']['campaigns'][0]['is_applied']).to be_truthy
        expect(data['order_price']['campaigns'][0]['title']).to eq(campaign_rule.title)
        expect(data['order_price']['campaigns'][0]['left_to_apply']).to eq(0)
        expect(data['order_price']['campaigns'][0]['discount_amount']).to eq(100)
      end
    end

    context "when order have asigned shopping point campaign" do
      let!(:campaign_rule){ FactoryGirl.create(:exceed_amount_money_off_shopping_point_campaign_rule, threshold: 500) }
      let!(:shopping_point_campaign) { FactoryGirl.create(:shopping_point_campaign, campaign_rule: campaign_rule, amount: 100) }
      it "does apply get shopping point and return shopping point campaign info" do
        post :checkout, user_id: user.id, products: products, is_spend_shopping_point: false
        data = JSON.parse(response.body)["data"]

        expect(data['order_price']['obtain_shopping_point_amount']).to eq(100)
        expect(data['order_price']['shopping_point_campaigns'][0]['is_applied']).to be_truthy
        expect(data['order_price']['shopping_point_campaigns'][0]['title']).to eq(campaign_rule.title)
        expect(data['order_price']['shopping_point_campaigns'][0]['left_to_apply']).to eq(0)
      end
    end

    context "when user choose to spend shopping point" do
      let!(:quantity) { 5 }
      let!(:campaign_rule){ FactoryGirl.create(:exceed_amount_money_off_campaign_rule, threshold: 1000, discount_money: 100) }
      let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule) }
      let!(:spendable_shopping_point_amount){ ShoppingPointManager.new(user).calculate_available_shopping_point(items_price) }
      it "does reduce items_price and all_items campaigns will apply on that price" do
        post :checkout, user_id: user.id, products: products, is_spend_shopping_point: true
        data = JSON.parse(response.body)["data"]

        expect(data['order_price']['origin_items_price']).to eq(items_price)
        expect(data['order_price']['shopping_point']['spendable_amount']).to eq(spendable_shopping_point_amount)
        expect(data['order_price']['shopping_point']['used_amount']).to eq(spendable_shopping_point_amount)
        expect(data['order_price']['shopping_point']['reduced_items_price']).to eq(items_price - spendable_shopping_point_amount)
        expect(data['order_price']['campaigns'][0]['is_applied']).to be_falsy
        expect(data['order_price']['campaigns'][0]['title']).to eq(campaign_rule.title)
        expect(data['order_price']['campaigns'][0]['left_to_apply']).to eq(campaign_rule.left_to_apply(amount: items_price - spendable_shopping_point_amount))
        expect(data['order_price']['campaigns'][0]['discount_amount']).to eq(0)
      end
    end
  end

  describe "post #create" do
    let!(:store) { FactoryGirl.create(:store) }
    let!(:uid) { user.uid }
    let!(:ship_fee) { 0 }
    let!(:total) { items_price + ship_fee }
    let!(:registration_id) { user.devices.first.registration_id }
    let!(:ship_address) { Faker::Address.street_address }
    let!(:ship_name) { Faker::Name.name }
    let!(:ship_phone) { Faker::PhoneNumber.phone_number }
    let!(:ship_store_code) {store.store_code}
    let!(:ship_store_id) { store.id }
    let!(:ship_store_name) { store.name }
    let!(:ship_email) { Faker::Internet.email }
    let!(:product) { {product_id: item.id, name: item.name, spec_id: spec.id, style: spec.style, quantity: quantity, price: item.price} }
    let!(:products) { [product] }

    context 'when item spec is on shelf and stock spec is sufficient' do
      let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 5) }
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
        let!(:spend_amount) { ShoppingPointManager.new(user).total_amount }
        it "does spend user's shopping point" do
          post :create, email: user.email, items_price: items_price, ship_fee: ship_fee, total: total,
               registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
               ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
               ship_email: ship_email, products: products, shopping_points_amount: spend_amount
          order_id = JSON.parse(response.body)["data"]["id"]

          user.shopping_points.each do |shopping_point|
            expect(shopping_point.shopping_point_records.last.order_id).to eq(order_id)
          end
          expect(ShoppingPointManager.new(user).total_amount).to eq(0)
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

      context "when ship type is home delivery by credit card" do
        it "does create correct order" do
          post :create, email: user.email, items_price: items_price, ship_fee: ship_fee, total: total,
               registration_id: registration_id, ship_type: home_delivery_by_credit_card_type, ship_name: ship_name, ship_phone: ship_phone,
               ship_address: ship_address, ship_email: ship_email, products: products
          order_id = JSON.parse(response.body)["data"]['id']
          order = Order.find(order_id)
          expect(order.items_price).to eq(items_price)
          expect(order.ship_fee).to eq(ship_fee)
          expect(order.total).to eq(total)
          expect(order.device_registration_id).to eq(DeviceRegistration.find_by(registration_id: registration_id).id)
          expect(order.ship_type).to eq(home_delivery_by_credit_card_type)
          expect(order.info.ship_email).to eq(ship_email)
          expect(order.info.ship_address).to eq(ship_address)
          expect(order.items.size).to eq(products.size)
          expect(order.items[0].item_name).to eq(product[:name])
        end
      end

      context "when product has applied campaign" do
        let!(:campaign_rule){ FactoryGirl.create(:exceed_quantity_percentage_off_campaign_rule, threshold: 3, discount_percentage: 0.9) }
        let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule, discountable: item) }
        it "does create order_item discount_record" do
          post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
               registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
               ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
               ship_email: ship_email, products: products
          order_id = JSON.parse(response.body)["data"]['id']
          order = Order.find(order_id)
          expect(order.items[0].discount_record.campaign_rule_id).to eq(campaign_rule.id)
        end
      end

      context "when order has applied campaign" do
        let!(:campaign_rule){ FactoryGirl.create(:exceed_amount_money_off_campaign_rule, threshold: 300, discount_money: 100) }
        let!(:campaign) { FactoryGirl.create(:campaign, campaign_rule: campaign_rule) }
        it "does create order_discount_record" do
          post :create, uid: uid, items_price: items_price, ship_fee: ship_fee, total: total,
               registration_id: registration_id, ship_type: store_delivery_type, ship_name: ship_name, ship_phone: ship_phone,
               ship_store_code: ship_store_code, ship_store_id: ship_store_id, ship_store_name: ship_store_name,
               ship_email: ship_email, products: products
          order_id = JSON.parse(response.body)["data"]['id']
          order = Order.find(order_id)
          expect(order.discount_records[0].campaign_rule_id).to eq(campaign_rule.id)
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

    context 'when order is home delivery by credit card' do
      let!(:home_delivery_by_credit_card_order) { FactoryGirl.create(:order, items: [order_item], ship_type: home_delivery_by_credit_card_type) }
      let!(:home_delivery_by_credit_card_order_info) { FactoryGirl.create(:home_delivery_by_credit_card_order_info, order: home_delivery_by_credit_card_order) }

      it 'does generate correct order info' do
        get :show, id: home_delivery_by_credit_card_order.id
        result = JSON.parse(response.body)["data"]
        order = Order.find(home_delivery_by_credit_card_order.id)
        json = order.generate_result_order.to_json
        expect(result.to_json).to eq(json)
      end
    end

    context "when order has discount_record" do
      let!(:campaign_rule) {FactoryGirl.create(:exceed_amount_money_off_campaign_rule, discount_money: 100, threshold: 1000)}
      let!(:campaign) {FactoryGirl.create(:campaign, campaign_rule: campaign_rule)}
      let!(:home_delivery_order) { FactoryGirl.create(:order, items: [order_item], ship_type: home_delivery_type) }
      let!(:discount_record) {FactoryGirl.create(:discount_record, campaign_rule: campaign_rule, discountable: home_delivery_order)}
      let!(:home_delivery_order_info) { FactoryGirl.create(:home_delivery_order_info, order: home_delivery_order) }
      it 'does generate correct order info' do
        get :show, id: home_delivery_order.id
        result = JSON.parse(response.body)["data"]
        expect(result['campaigns'][0]['title']).to eq campaign_rule.title
        expect(result['campaigns'][0]['discount_amount']).to eq campaign_rule.discount_money
      end
    end

    context "when order has shpping point record" do
      let!(:campaign_rule) {FactoryGirl.create(:exceed_amount_money_off_shopping_point_campaign_rule, threshold: 1000)}
      let!(:shopping_point_campaign) {FactoryGirl.create(:shopping_point_campaign, title: campaign_rule.title, campaign_rule: campaign_rule, amount: 100)}
      let!(:shopping_point) {FactoryGirl.create(:campaign_point, shopping_point_campaign: shopping_point_campaign, user: user, amount: 100)}
      let!(:home_delivery_order) { FactoryGirl.create(:order, items: [order_item], ship_type: home_delivery_type) }
      let!(:home_delivery_order_info) { FactoryGirl.create(:home_delivery_order_info, order: home_delivery_order) }
      it 'does generate correct order info' do
        shopping_point.shopping_point_records.first.update_column(:order_id, home_delivery_order.id)
        get :show, id: home_delivery_order.id
        result = JSON.parse(response.body)["data"]
        expect(result['shopping_point_campaigns'][0]['title']).to eq shopping_point_campaign.title
      end
    end

    context "when order item has discount record" do
      let!(:campaign_rule) {FactoryGirl.create(:exceed_quantity_percentage_off_campaign_rule, discount_percentage: 0.5, threshold: 3)}
      let!(:campaign) {FactoryGirl.create(:campaign, campaign_rule: campaign_rule, discountable: item)}
      let!(:home_delivery_order) { FactoryGirl.create(:order, items: [order_item], ship_type: home_delivery_type) }
      let!(:discount_record) {FactoryGirl.create(:discount_record, campaign_rule: campaign_rule, discountable: order_item)}
      let!(:home_delivery_order_info) { FactoryGirl.create(:home_delivery_order_info, order: home_delivery_order) }
      it 'does generate correct order info' do
        get :show, id: home_delivery_order.id
        result = JSON.parse(response.body)["data"]
        expect(result['items'][0]['campaign']['title']).to eq campaign_rule.title
      end
    end
  end

  describe "post#check_pickup_record" do
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 20) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    context "when anonymous user" do
      let!(:user) { FactoryGirl.create(:anonymous_user) }
      context "when not-pickup order does exist" do
        let!(:order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: store_delivery_type, status: Order.statuses["未取訂貨"]) }
        let!(:info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
        context "when not-pickup order's created_at within 30 days" do
          it "should return status code 203 and message" do
            post :check_pickup_record, user_id: user.id, ship_email: info.ship_email, ship_phone: info.ship_phone
            error = JSON.parse(response.body)["error"]
            expect(error["code"]).to eq(203)
            expect(error["message"]).to be_present
          end
        end

        context "when not-pickup order's created_at over 30 days" do
          it "should return success" do
            order.update_column(:created_at, Time.current - 31.days)
            post :check_pickup_record, user_id: user.id, ship_email: info.ship_email, ship_phone: info.ship_phone
            data = JSON.parse(response.body)["data"]
            expect(data).to eq("success")
          end
        end
      end

      context "when not-pickup order does not exist" do
        let!(:order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: store_delivery_type, status: Order.statuses["完成取貨"]) }
        let!(:info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
        it "should return success" do
          post :check_pickup_record, user_id: user.id, ship_email: info.ship_email, ship_phone: info.ship_phone
          data = JSON.parse(response.body)["data"]
          expect(data).to eq("success")
        end
      end
    end

    context "when registered user" do
      let!(:user) { FactoryGirl.create(:user) }
      context "when not-pickup order does exist" do
        let!(:order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: store_delivery_type, status: Order.statuses["未取訂貨"]) }
        let!(:info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
        context "when not-pickup order's created_at within 30 days" do
          it "should return status code 203 and message" do
            post :check_pickup_record, user_id: user.id, ship_email: info.ship_email, ship_phone: info.ship_phone
            error = JSON.parse(response.body)["error"]
            expect(error["code"]).to eq(203)
            expect(error["message"]).to be_present
          end
        end

        context "when not-pickup order's created_at over 30 days" do
          it "should return success" do
            order.update_column(:created_at, Time.current - 31.days)
            post :check_pickup_record, user_id: user.id, ship_email: info.ship_email, ship_phone: info.ship_phone
            data = JSON.parse(response.body)["data"]
            expect(data).to eq("success")
          end
        end
      end

      context "when not-pickup order does not exist" do
        let!(:order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: store_delivery_type, status: Order.statuses["完成取貨"]) }
        let!(:info) { FactoryGirl.create(:store_delivery_order_info, order: order) }
        it "should return success" do
          post :check_pickup_record, user_id: user.id, ship_email: info.ship_email, ship_phone: info.ship_phone
          data = JSON.parse(response.body)["data"]
          expect(data).to eq("success")
        end
      end
    end
  end

  describe "get#by_user_email" do
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 40) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:store_delivery_order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: store_delivery_type) }
    let!(:store_delivery_info) { FactoryGirl.create(:store_delivery_order_info, order: store_delivery_order) }
    context "when orders contain paid credit card order" do
      let!(:paid_credit_card_order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: home_delivery_by_credit_card_type, is_paid: true) }
      let!(:paid_credit_card_info) { FactoryGirl.create(:home_delivery_by_credit_card_order_info, order: paid_credit_card_order) }
      let!(:orders) { user.orders.exclude_unpaid_credit_card_orders.recent }
      it 'does generate correct order list' do
        get :by_user_email, email: user.email
        data = JSON.parse(response.body)["data"]
        expect(data.size).to eq(orders.size)
        expect(data[0]['id']).to eq(orders[0].id)
        expect(data[0]['user_id']).to eq(orders[0].user_id)
        expect(data[0]['total']).to eq(orders[0].total)
        expect(data[0]['status']).to eq(orders[0].status)
        expect(data[0]['created_on']).to eq(orders[0].created_at.strftime("%Y-%m-%d"))
      end
    end

    context "when orders contain unpaid credit card order" do
      let!(:unpaid_credit_card_order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: home_delivery_by_credit_card_type) }
      let!(:unpaid_credit_card_info) { FactoryGirl.create(:home_delivery_by_credit_card_order_info, order: unpaid_credit_card_order) }
      let!(:orders) { user.orders.exclude_unpaid_credit_card_orders }
      it 'does generate correct order list' do
        get :by_user_email, email: user.email
        data = JSON.parse(response.body)["data"]
        expect(data.size).to eq(orders.size)
        expect(data[0]['id']).to eq(orders[0].id)
        expect(data[0]['user_id']).to eq(orders[0].user_id)
        expect(data[0]['total']).to eq(orders[0].total)
        expect(data[0]['status']).to eq(orders[0].status)
        expect(data[0]['created_on']).to eq(orders[0].created_at.strftime("%Y-%m-%d"))
      end
    end
  end

  describe "get#by_email_phone" do
    let!(:stock_spec) { FactoryGirl.create(:stock_spec, item: item, item_spec: spec, amount: 40) }
    let!(:order_item) { FactoryGirl.create(:order_item, item_spec: spec, item: spec.item) }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email) { "example@domain.com" }
    let!(:phone) { "0912346789" }
    let!(:store_delivery_order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: store_delivery_type) }
    let!(:store_delivery_info) { FactoryGirl.create(:store_delivery_order_info, order: store_delivery_order, ship_email: email, ship_phone: phone) }
    context "when orders contain paid credit card order" do
      let!(:paid_credit_card_order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: home_delivery_by_credit_card_type, is_paid: true) }
      let!(:paid_credit_card_info) { FactoryGirl.create(:home_delivery_by_credit_card_order_info, order: paid_credit_card_order, ship_email: email, ship_phone: phone) }
      let!(:orders) { Order.joins(:info).where("order_infos.ship_email = :ship_email AND order_infos.ship_phone = :ship_phone", ship_email: email, ship_phone: phone).exclude_unpaid_credit_card_orders.recent }
      it 'does generate correct order list' do
        get :by_email_phone, ship_email: email, ship_phone: phone
        data = JSON.parse(response.body)["data"]
        expect(data.size).to eq(orders.size)
        expect(data[0]['id']).to eq(orders[0].id)
        expect(data[0]['user_id']).to eq(orders[0].user_id)
        expect(data[0]['total']).to eq(orders[0].total)
        expect(data[0]['status']).to eq(orders[0].status)
        expect(data[0]['created_on']).to eq(orders[0].created_at.strftime("%Y-%m-%d"))
      end
    end

    context "when orders contain unpaid credit card order" do
      let!(:unpaid_credit_card_order) { FactoryGirl.create(:order, user: user, items: [order_item], ship_type: home_delivery_by_credit_card_type) }
      let!(:unpaid_credit_card_info) { FactoryGirl.create(:home_delivery_by_credit_card_order_info, order: unpaid_credit_card_order, ship_email: email, ship_phone: phone) }
      let!(:orders) { Order.joins(:info).where("order_infos.ship_email = :ship_email AND order_infos.ship_phone = :ship_phone", ship_email: email, ship_phone: phone).exclude_unpaid_credit_card_orders.recent }
      it 'does generate correct order list' do
        get :by_email_phone, ship_email: email, ship_phone: phone
        data = JSON.parse(response.body)["data"]
        expect(data.size).to eq(orders.size)
        expect(data[0]['id']).to eq(orders[0].id)
        expect(data[0]['user_id']).to eq(orders[0].user_id)
        expect(data[0]['total']).to eq(orders[0].total)
        expect(data[0]['status']).to eq(orders[0].status)
        expect(data[0]['created_on']).to eq(orders[0].created_at.strftime("%Y-%m-%d"))
      end
    end
  end
end