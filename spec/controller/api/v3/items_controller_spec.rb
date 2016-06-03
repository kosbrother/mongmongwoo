require 'spec_helper'

describe Api::V3::ItemsController, :type => :controller  do
  describe "get #show" do
    it 'does contain correct json' do
      item =  FactoryGirl.create(:item_with_specs_and_photos)
      get :show, id: item
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['name']).to eq(item.name)
      expect(json['price']).to eq(item.price)
      expect(json['cover']).to eq(item.cover.url)
      expect(json['description']).to eq(item.description)
      expect(json['status']).to eq(item.status)
      expect(json['photos']).to match_array(item.photos.collect { |photo| {"image_url" => photo.image.url} })
      expect(json['specs']).to match_array(item.specs.on_shelf.collect { |spec| {"id" => spec.id, "style" => spec.style,
                                                                        "style_pic" => spec.style_pic.url}})
    end
  end
end