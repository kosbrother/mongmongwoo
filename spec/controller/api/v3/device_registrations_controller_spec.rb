require 'rails_helper'

RSpec.describe Api::V3::DeviceRegistrationsController, type: :controller do
  describe "POST create" do
    context "when registration id has already existed" do
      let!(:device_registration) { FactoryGirl.create(:device_registration, registration_id: "some_example_registration_id") }

      it "should not create a new device registration record" do
        origin_count = DeviceRegistration.count
        post :create, registration_id: device_registration.registration_id
        expect(DeviceRegistration.count).to eq(origin_count)
      end
    end

    context "when registration_id has not existed" do
      let!(:device_registration) { FactoryGirl.create(:device_registration, registration_id: "some_example_registration_id") }

      it "should create a new device registration record" do
        origin_count = DeviceRegistration.count
        post :create, registration_id: "another_example_registration_id"
        expect(DeviceRegistration.count).to eq(origin_count + 1)
      end

      it "should be present after creating the new record" do
        post :create, registration_id: "new_example_registration_id"
        expect(DeviceRegistration.find_by(registration_id: "new_example_registration_id")).to be_truthy
      end
    end
  end
end