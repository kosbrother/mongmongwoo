require 'spec_helper'

RSpec.describe Api::V3::UsersController, :type => :controller do
  describe "post #create" do
    let!(:uid) {Faker::Number.number(10)}
    let!(:user_name) { Faker::Internet.user_name }
    let!(:email) { Faker::Internet.email }

    before :each do
      post :create, uid: uid, user_name: user_name,
                    email: email
    end

    context "when give a new user" do
      it 'does create correct user' do
        user = User.find_by(uid: uid)
        expect(user.uid).to eq(uid)
        expect(user.user_name).to eq(user_name)
        expect(user.email).to eq(email)
      end
    end

    context "when give a exist user" do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:uid) { user.uid }
      it "does not create new user" do
        expect(User.where(uid: user.uid).size).to eq(1)
      end
    end
  end
end
