require 'rails_helper'

RSpec.describe Api::V4::MyMessagesController, type: :controller do
  describe "GET index" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:official_message) { FactoryGirl.create(:official_message) }
    let!(:personal_message) { FactoryGirl.create(:personal_message, users: [user]) }

    it "should contain correct message quantity and data" do
      get :index, user_id: user.id
      data = JSON.parse(response.body)["data"]

      expect(data.count).to eq(user.my_messages.count)
      expect(data).to match_array(user.my_messages.order(id: :desc).as_json(only: [:id, :message_type, :title, :content, :created_at], methods: :app_index_url))
    end
  end
end