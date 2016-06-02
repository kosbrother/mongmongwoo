require 'rails_helper'

RSpec.describe Api::V3::DeviceRegistrationsController, type: :controller do
  describe "POST create" do
    context "when registration id has already existed" do
      let!(:device_registration) { FactoryGirl.create(:device_registration, registration_id: "some_example_registration_id") }
      it "should not create a new device registration record" do
        post :create, registration_id: "some_example_registration_id"
        expect(DeviceRegistration.count).to eq(1)
      end
    end

    context "when registration_id has not existed" do
      let!(:device_registration) { FactoryGirl.create(:device_registration, registration_id: "some_example_registration_id") }
      it "should create a new device registration record" do
        post :create, registration_id: "another_example_registration_id"
        expect(DeviceRegistration.count).to eq(2)
      end
    end
  end
end