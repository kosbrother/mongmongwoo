require 'spec_helper'
RSpec.describe Api::V3::OauthSessionsController, type: :controller do
  describe "post #create" do
    let!(:email) { Faker::Internet.email }
    let!(:uid) {Faker::Number.number(10)}
    let!(:user_name) { Faker::Internet.user_name }
    let!(:gender) { 'female' }
    let!(:provider) {'facebook'}
    before :each do
      post :create, email: email, uid: uid, provider: provider, user_name: user_name, gender: gender
    end

    context 'when user and login does not exist' do
      it 'does create new user and new fb login' do
        user = User.find_by(email: email)
        login = user.logins.find_by(provider: provider, uid: uid)
        expect(user).to be_present
        expect(login).to be_present
        expect(login.user_name).to eq(user_name)
        expect(login.gender).to eq(gender)
      end
    end


    context 'when user and login exist' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:login) { FactoryGirl.create(:login, :facebook, user_id: user.id) }
      let!(:uid) { login.uid }
      let!(:user_name) { login.user_name }
      let!(:email) { user.email }

      it 'does not create new user and new fb login' do
        expect(User.where(email: email).size).to eq(1)
        expect(Login.where(provider: provider, uid: uid).size).to eq(1)
      end


      context 'when login from different provider with same email' do
        let!(:provider) { 'google' }
        it 'does belong to same user and create new provider login' do
          another_login = Login.find_by(provider: provider, uid: uid)
          expect(User.where(email: email).size).to eq(1)
          expect(another_login).to be_present
        end
      end
    end

    context 'when email is not provided' do
      let!(:email) { nil }
      it_behaves_like  "return JSON 400 status code with error message"
    end
    context 'when provider is not provided' do
      let!(:provider) { nil }
      it_behaves_like  "return JSON 400 status code with error message"
    end
  end
end
