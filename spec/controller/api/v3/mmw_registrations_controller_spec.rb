require 'spec_helper'
RSpec.describe Api::V3::MmwRegistrationsController, :type => :controller do
  describe "post #create" do
    let!(:email) { Faker::Internet.email }
    let!(:password) { Faker::Internet.password }

    before :each do
      post :create, email: email, password: password
    end

    it 'should create new user' do

      user = User.find_by(email: email)
      expect(user).to be_present
    end
  end
end
