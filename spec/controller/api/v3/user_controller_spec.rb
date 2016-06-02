require 'spec_helper'

RSpec.describe Api::V3::UsersController, :type => :controller do
  context "post #create" do
    it 'does create correct user' do
      uid = Faker::Number.number(10)
      user_name = Faker::Internet.user_name
      real_name = Faker::Name.name
      email = Faker::Internet.email
      phone =  Faker::PhoneNumber.phone_number
      address = Faker::Address.street_address
      post :create, uid: uid, user_name: user_name,
                   real_name: real_name, email: email,
                  phone: phone, address: address
      user = User.find_by(uid: uid)
      expect(user.uid).to eq(uid)
      expect(user.user_name).to eq(user_name)
      expect(user.real_name).to eq(real_name)
      expect(user.email).to eq(email)
      expect(user.phone).to eq(phone)
      expect(user.address).to eq(address)
    end
  end
end