require 'spec_helper'

RSpec.describe Api::V4::OauthSessionsController, type: :controller do
  describe "post #create" do
    let!(:email) { Faker::Internet.email }
    let!(:uid) {Faker::Number.number(10)}
    let!(:user_name) { Faker::Internet.user_name }
    let!(:gender) { 'female' }
    let!(:provider) {'facebook'}
    let!(:device) { FactoryGirl.create(:device_registration) }

    it_behaves_like "when registration_id is empty" do
      let(:action) { post :create }
    end

    before :each do
      post :create, email: email, uid: uid, provider: provider, user_name: user_name, gender: gender, registration_id: device.registration_id
    end

    context 'when user and login does not exist' do
      it 'does create new user and new fb login' do
        user = User.find_by(email: email)
        login = user.logins.find_by(provider: provider, uid: uid)
        expect(user).to be_present
        expect(user.devices).to include(device)
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
      let!(:origin_users_count) { User.count }
      let!(:origin_logins_count) { Login.count }

      it 'does not create new user and new fb login' do
        expect(user.devices).to include(device)
        expect(User.where(email: email).count).to eq(origin_users_count)
        expect(Login.where(provider: provider, uid: uid).count).to eq(origin_logins_count)
      end


      context 'when login from different provider with same email' do
        let!(:provider) { 'facebook' }

        it 'does belong to same user and create new provider login' do
          another_login = Login.find_by(provider: provider, uid: uid)
          expect(user.devices).to include(device)
          expect(User.where(email: email).count).to eq(origin_users_count)
          expect(another_login).to be_present
        end
      end
    end

    context 'when email is not provided' do
      let!(:email) { nil }

      it 'does not create new user and new fb login' do
        error_message = response.body
        expect(error_message).to eq(I18n.t('activerecord.errors.models.user.attributes.email.blank') + ', ' + I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
        expect(User.where(email: email)).to be_empty
        expect(Login.where(provider: provider, uid: uid)).to be_empty
        expect(device.user).to be_nil
      end
    end

    context 'when provider is not provided' do
      let!(:provider) { nil }

      it 'does not create new user and new fb login' do
        error_message = response.body
        expect(error_message).to eq(I18n.t('activerecord.errors.models.login.attributes.provider.blank'))
        expect(User.where(email: email)).to be_empty
        expect(Login.where(provider: provider, uid: uid)).to be_empty
        expect(device.user).to be_nil
      end
    end

    context 'when uid is not provided' do
      let!(:uid) { nil }

      it 'does not create new user and new fb login' do
        error_message = response.body
        expect(error_message).to eq(I18n.t('activerecord.errors.models.login.attributes.uid.blank'))
        expect(User.where(email: email)).to be_empty
        expect(Login.where(provider: provider, uid: uid)).to be_empty
        expect(device.user).to be_nil
      end
    end
  end
end
