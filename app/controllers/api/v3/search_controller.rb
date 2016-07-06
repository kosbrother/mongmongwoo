class  Api::V3::SearchController < ApiController
  def search_items
    items =  Item.search_for_name_and_description(params[:term]).page(params[:page]).per_page(20).records
    render status: 200, json: items, only: [:id, :name, :cover]
  end
end
