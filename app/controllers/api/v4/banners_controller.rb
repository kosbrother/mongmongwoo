class Api::V4::BannersController < ApiController
  include Admin::BannersHelper

  def index
    data_hash = {}
    banners = Banner.recent

    banners.each_with_index do |banner, index|
      data = banner.as_json(except: [:created_at, :updated_at])
      data["url"] = bannerable_url(banner)
      data_hash[index] = data
    end

    data_hash = data_hash.values
    render status: 200, json: { data: data_hash }
  end
end