require 'spec_helper'
RSpec.describe Api::V3::FbRegistrationsController, type: :controller do
  describe "post #create" do
    let!(:email) { Faker::Internet.email }
    let!(:uid) {Faker::Number.number(10)}
    let!(:user_name) { Faker::Internet.user_name }
    let!(:gender) { 'female' }
    before :each do
      post :create, email: email, uid: uid, user_name: user_name, gender: gender
    end

    context 'when user and login does not exist' do
      it 'does create new user and new fb login' do
        user = User.find_by(email: email)
        login = user.logins.find_by(provider: 'facebook', uid: uid)
        expect(user).to be_present
        expect(login).to be_present
        expect(login.user_name).to eq(user_name)
        expect(login.gender).to eq(gender)
      end
    end


    context 'when user and login exist' do
      user = FactoryGirl.create(:user)
      login = FactoryGirl.create(:login, :facebook, user_id: user.id)
      let!(:uid) { login.uid }
      let!(:user_name) { login.user_name }
      let!(:email) { user.email }

      it 'does not create new user and new fb login' do
        expect(User.where(email: email).size).to eq(1)
        expect(Login.where(provider: 'facebook', uid: uid).size).to eq(1)
      end
    end
  end
end
