require 'spec_helper'

describe ApiController, :type => :controller  do
  describe 'get android_version' do
    it 'should contain correct info' do
      FactoryGirl.create(:android_version)
      get :android_version
      info = ActiveSupport::JSON.decode(response.body)
      expect(info["version_code"]).not_to be_nil
      expect(info["version_name"]).not_to be_nil
      expect(info["update_message"]).not_to be_nil
    end
  end

  describe 'redirect to new app url' do
    it 'does return boolean value and app url' do
      get :get_new_app
      data = JSON.parse(response.body)

      expect(data["is_ready"]).to be_falsy
      expect(data["url"]).to be_present
      expect(data["coupon"]).to be_present
    end
  end
end
