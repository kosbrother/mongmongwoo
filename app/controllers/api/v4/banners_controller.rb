class Api::V4::BannersController < ApiController
  def index
    banners = Banner.recent.as_json(except: [:created_at, :updated_at], methods: :app_index_url)

    render status: 200, json: { data: banners }
  end
end