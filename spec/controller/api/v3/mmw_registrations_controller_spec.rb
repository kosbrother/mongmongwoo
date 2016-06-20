require 'spec_helper'
RSpec.describe Api::V3::MmwRegistrationsController, :type => :controller do
  let!(:email) { Faker::Internet.email }
  let!(:password) { Faker::Internet.password }
  describe 'post #create' do

    before :each do
      post :create, email: email, password: password
    end

    it 'should create new user' do
      user = User.find_by(email: email)
      message = JSON.parse(response.body)['data']
      expect(user).to be_present
      expect(response.status).to eq(200)
      expect(response.content_type).to eq 'application/json'
      expect(message).not_to be_nil
    end

    context 'when email is empty' do
      let!(:email) { '' }
      it 'does not create new user and return status 400' do
        message = JSON.parse(response.body)['error']
        expect(User.all.size).to eq(0)
        expect(response.status).to eq(400)
        expect(response.content_type).to eq 'application/json'
        expect(message).not_to be_nil
      end
    end
  end

  describe 'post #login' do
    let!(:user) { FactoryGirl.create(:user, email: email, password: password) }

    context 'when password is correct' do
      it 'does find the user and pass the correct password' do
        post :login, email: email, password: password
        message = JSON.parse(response.body)['data']
        expect(response.status).to eq(200)
        expect(response.content_type).to eq 'application/json'
        expect(message).not_to be_nil
      end
    end

    context 'when password is not correct' do
      it 'does not pass the wrong password' do
        post :login, email: email, password: '1234'
        message = JSON.parse(response.body)['error']
        expect(response.status).to eq(400)
        expect(response.content_type).to eq 'application/json'
        expect(message).not_to be_nil
      end
    end

    context 'when no user email match' do
      it 'does not pass login' do
        post :login, email: 'test@test.com', password: '1234'
        message = JSON.parse(response.body)['error']
        expect(response.status).to eq(400)
        expect(response.content_type).to eq 'application/json'
        expect(message).not_to be_nil
      end
    end
  end

  describe 'post #forget' do
    let!(:user) { FactoryGirl.create(:user, email: email, password: password) }

    context 'when user provide exist email' do
      it 'does find the user and create password reset token' do
        post :forget, email: email
        user = User.find_by_email(email)
        expect(user).to be_present
        expect(user.password_reset_token).to_not be_nil
        expect(response.status).to eq(200)
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'when user did not provide correct email' do
      it 'return 400 status code' do
        post :forget, email: 'xxxxx'
        message = JSON.parse(response.body)['error']
        expect(response.status).to eq(400)
        expect(response.content_type).to eq 'application/json'
        expect(message).not_to be_nil
      end
    end
  end
end
