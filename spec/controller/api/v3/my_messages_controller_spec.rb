require 'rails_helper'

RSpec.describe Api::V3::MyMessagesController, type: :controller do
  describe "GET index" do
    let!(:alice) { FactoryGirl.create(:user) }
    let!(:official_message) { FactoryGirl.create(:official_message) }
    let!(:personal_message) { FactoryGirl.create(:personal_message, users: [alice]) }
    let!(:user) { User.find(alice.id) }

    it "should contain correct message quantity" do
      get :index, user_id: user.id
      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(user.my_messages.count)
    end

    it "should contain correct message data" do
      get :index, user_id: user.id
      data = JSON.parse(response.body)["data"]
      expect(data).to match_array(user.my_messages.select_api_fields.as_json)
    end
  end

  describe "GET show" do
    let!(:alice) { FactoryGirl.create(:user) }
    let!(:official_message) { FactoryGirl.create(:official_message) }
    let!(:personal_message) { FactoryGirl.create(:personal_message, users: [alice]) }
    let!(:user) { User.find(alice.id) }

    it "should contain correct official message data" do
      get :show, user_id: user.id, id: official_message.id
      data = JSON.parse(response.body)["data"]
      expect(data).to match_array(user.my_messages.select_api_fields.find(official_message.id).as_json)
    end

    it "should contain correct persernal message data" do
      get :show, user_id: user.id, id: personal_message.id
      data = JSON.parse(response.body)["data"]
      expect(data).to match_array(user.my_messages.select_api_fields.find(personal_message.id).as_json)
    end
  end
end