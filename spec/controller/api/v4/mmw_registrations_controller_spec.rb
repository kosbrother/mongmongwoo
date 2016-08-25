require 'spec_helper'

RSpec.describe Api::V4::MmwRegistrationsController, :type => :controller do
  let!(:email) { Faker::Internet.email }
  let!(:password) { Faker::Internet.password }
  let!(:device) { FactoryGirl.create(:device_registration) }

  describe 'post #create' do

    it_behaves_like "when registration_id is empty" do
      let(:action) { post :create }
    end

    it 'should create new user' do
      post :create, email: email, password: password, registration_id: device.registration_id
      user = User.find_by(email: email)
      message = JSON.parse(response.body)['data']
      expect(user).to be_present
      expect(user.devices).to include(device)
      expect(message).to eq(user.id)
    end

    context 'when user with same email exist' do
      context 'when user is not registered' do
        let!(:user) { FactoryGirl.create(:user, email: email)}

        it 'does register the exist user' do
          post :create, email: email, password: password, registration_id: device.registration_id
          user = User.find_by(email: email)
          message = JSON.parse(response.body)['data']
          expect(user.is_mmw_registered).to be_truthy
          expect(user.devices).to include(device)
          expect(message).to eq(user.id)
        end
      end

      context 'when user is registered' do
        let!(:user) { FactoryGirl.create(:user, email: email, is_mmw_registered: true) }
        let!(:origin_users_count) { User.count }

        it 'does not create new user' do
          post :create, email: email, password: password, registration_id: device.registration_id
          message = response.body
          expect(User.count).to eq(origin_users_count)
          expect(user.devices).not_to include(device)
          expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.email.taken'))
        end
      end
    end

    context 'when registration dada empty' do
      before :each do
        post :create, email: email, password: password, registration_id: device.registration_id
      end

      context 'when email is empty' do
        let!(:email) { '' }
        let!(:origin_users_count) { User.count }

        it 'does not create new user' do
          message = response.body
          expect(User.count).to eq(origin_users_count)
          expect(device.user).to be_nil
          expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.email.blank') + ' ' + I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
        end
      end

      context 'when email format is wrong' do
        let!(:email) { '12345678' }
        let!(:origin_users_count) { User.count }

        it 'does not create new user' do
          message = response.body
          expect(User.count).to eq(origin_users_count)
          expect(device.user).to be_nil
          expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
        end
      end

      context 'when password is empty' do
        let!(:password) { '' }
        let!(:origin_users_count) { User.count }

        it 'does not create new user' do
          message = response.body
          expect(User.count).to eq(origin_users_count)
          expect(device.user).to be_nil
          expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.password.blank'))
        end
      end
    end
  end

  describe 'post #login' do
    let!(:user) { FactoryGirl.create(:user, email: email, password: password, is_mmw_registered: true) }

    context 'when password is correct' do
      it 'does find the user and pass the correct password' do
        post :login, email: email, password: password, registration_id: device.registration_id
        message = JSON.parse(response.body)['data']
        expect(message).to eq(user.id)
        expect(user.devices).to include(device)
      end
    end

    context 'when password is not correct' do
      it 'does not pass the wrong password' do
        post :login, email: email, password: '1234', registration_id: device.registration_id
        message = response.body
        expect(device.user).to be_nil
        expect(message).to eq(I18n.t('controller.error.message.wrong_password'))
      end
    end

    context 'when no user email match' do
      it 'does not pass login' do
        post :login, email: 'test@test.com', password: '1234', registration_id: device.registration_id
        message = response.body
        expect(device.user).to be_nil
        expect(message).to eq(I18n.t('controller.error.message.no_user'))
      end
    end

    context 'when user with same email exist but is not registered' do
      let!(:user) { FactoryGirl.create(:user, email: email, password: password, is_mmw_registered: false) }
      it 'does not pass login' do
        post :login, email: 'test@test.com', password: '1234', registration_id: device.registration_id
        message = response.body
        expect(device.user).to be_nil
        expect(message).to eq(I18n.t('controller.error.message.no_user'))
      end
    end
  end
end