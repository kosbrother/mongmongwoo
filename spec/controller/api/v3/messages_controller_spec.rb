require 'rails_helper'

RSpec.describe Api::V3::MessagesController, type: :controller do
  describe "GET index" do
    let!(:official_message) { FactoryGirl.create(:official_message) }
    let!(:non_official_message) { FactoryGirl.create(:personal_message) }

    it "should contain correct message quantity" do
      get :index
      data = JSON.parse(response.body)
      expect(data.count).to eq(Message.official_messages.count)
    end
    
    it "should contain correct message data" do
      get :index
      data = JSON.parse(response.body)["data"]
      expect(data).to match_array(Message.official_messages.select_api_fields.as_json)
    end 
  end

  describe "GET show" do
    let!(:message) { FactoryGirl.create(:official_message) }

    it "should contain correct message data" do
      get :show, id: message.id
      data = JSON.parse(response.body)["data"]
      expect(data["id"]).to eq(message.id)
      expect(data["message_type"]).to eq(message.message_type)
      expect(data["title"]).to eq(message.title)
      expect(data["content"]).to eq(message.content)
      expect(data["created_at"].to_datetime.strftime("%Y-%m-%d %H:%M:%S")).to eq(message.created_at.strftime("%Y-%m-%d %H:%M:%S"))
    end
  end
end