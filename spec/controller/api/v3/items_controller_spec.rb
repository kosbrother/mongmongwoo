require 'spec_helper'

describe Api::V3::ItemsController, :type => :controller  do
  describe "get #show" do
    it 'does contain correct json' do
      item =  FactoryGirl.create(:item_with_specs_and_photos)
      get :show, id: item
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['name']).not_to be_nil
      expect(json['price']).not_to be_nil
      expect(json['cover']).not_to be_nil
      expect(json['description']).not_to be_nil
      expect(json['status']).not_to be_nil
      expect(json['photos']).not_to be_nil
      expect(json['specs']).not_to be_nil
    end
  end
end