class Api::V4::BannersController < ApiController
  def index
    banners = Banner.recent.as_json(only: [:id, :bannerable_id, :bannerable_type, :title, :image], methods: :app_index_url)

    render status: 200, json: { data: banners }
  end
end