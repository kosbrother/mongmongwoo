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
      expect(user).to be_present
    end
  end

  describe 'post #login' do
    let!(:user) { FactoryGirl.create(:user, email: email, password: password) }

    context 'when password is correct' do
      it 'does find the user and pass the correct password' do
        post :login, email: email, password: password
        expect(response.status).to eq(200)
      end
    end

    context 'when password is not correct' do
      it 'does not pass the wrong password' do
        post :login, email: email, password: '1234'
        expect(response.status).to eq(400)
      end
    end

    context 'when no user email match' do
      it 'does not pass login' do
        post :login, email: 'test@test.com', password: '1234'
        expect(response.status).to eq(400)
      end
    end
  end
end
