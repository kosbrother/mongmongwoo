require 'spec_helper'
RSpec.describe Api::V3::MmwRegistrationsController, :type => :controller do
  let!(:email) { Faker::Internet.email }
  let!(:password) { Faker::Internet.password }
  describe 'post #create' do

    it 'should create new user' do
      post :create, email: email, password: password
      user = User.find_by(email: email)
      message = JSON.parse(response.body)['data']
      expect(user).to be_present
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json')
      expect(message).to eq(user.id)
    end

    context 'when user with same email exist' do
      context 'when user is not registered' do
        let!(:user) { FactoryGirl.create(:user, email: email)}
        it 'does register the exist user' do
          post :create, email: email, password: password
          user = User.find_by(email: email)
          message = JSON.parse(response.body)['data']
          expect(user.is_mmw_registered).to be_truthy
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(message).to eq(user.id)
        end
      end

      context 'when user is registered' do
        let!(:user) { FactoryGirl.create(:user, email: email, is_mmw_registered: true) }
        it 'does not create new user and return status 400' do
          post :create, email: email, password: password
          message = JSON.parse(response.body)['error']['message']
          expect(User.count).to eq(1)
          expect(response.status).to eq(400)
          expect(response.content_type).to eq('application/json')
          expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.email.taken'))
        end
      end
    end

    context 'when email is empty' do
      let!(:email) { '' }
      it 'does not create new user and return status 400' do
        post :create, email: email, password: password
        message = JSON.parse(response.body)['error']['message']
        expect(User.count).to eq(0)
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.email.blank') + ' ' + I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
      end
    end

    context 'when email format is wrong' do
      let!(:email) { '12345678' }
      it 'does not create new user and return status 400' do
        post :create, email: email, password: password
        message = JSON.parse(response.body)['error']['message']
        expect(User.count).to eq(0)
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
      end
    end

    context 'when password is empty' do
      let!(:password) { '' }
      it 'does not create new user and return status 400' do
        post :create, email: email, password: password
        message = JSON.parse(response.body)['error']['message']
        expect(User.count).to eq(0)
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(I18n.t('activerecord.errors.models.user.attributes.password.blank'))
      end
    end
  end

  describe 'post #login' do
    let!(:user) { FactoryGirl.create(:user, email: email, password: password, is_mmw_registered: true) }

    context 'when password is correct' do
      it 'does find the user and pass the correct password' do
        post :login, email: email, password: password
        message = JSON.parse(response.body)['data']
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(user.id)
      end
    end

    context 'when password is not correct' do
      it 'does not pass the wrong password' do
        post :login, email: email, password: '1234'
        message = JSON.parse(response.body)['error']['message']
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(I18n.t('controller.error.message.wrong_password'))
      end
    end

    context 'when no user email match' do
      it 'does not pass login' do
        post :login, email: 'test@test.com', password: '1234'
        message = JSON.parse(response.body)['error']['message']
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(I18n.t('controller.error.message.no_user'))
      end
    end

    context 'when user with same email exist but is not registered' do
      let!(:user) { FactoryGirl.create(:user, email: email, password: password, is_mmw_registered: false) }
      it 'does not pass login' do
        post :login, email: 'test@test.com', password: '1234'
        message = JSON.parse(response.body)['error']['message']
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(I18n.t('controller.error.message.no_user'))
      end
    end
  end

  describe 'post #forget' do
    let!(:user) { FactoryGirl.create(:user, email: email, password: password, is_mmw_registered: true) }

    context 'when user provide exist email' do
      it 'does find the user and create password reset token' do
        post :forget, email: email
        user = User.find_by_email(email)
        message = JSON.parse(response.body)['data']
        expect(user).to be_present
        expect(user.password_reset_token).to_not be_nil
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq("success")
      end
    end

    context 'when user did not provide correct email' do
      it 'return 400 status code' do
        post :forget, email: 'xxxxx'
        message = JSON.parse(response.body)['error']['message']
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('application/json')
        expect(message).to eq(I18n.t('controller.error.message.no_user'))
      end
    end
  end
end