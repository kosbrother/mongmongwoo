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
end
