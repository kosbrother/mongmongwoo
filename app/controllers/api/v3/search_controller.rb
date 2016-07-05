class  Api::V3::SearchController < ApiController
  def search_items
    repository = Elasticsearch::Persistence::Repository.new
    repository.index = Item.index_name
    repository.type = 'item'
    items = repository.search({query: { multi_match: {query: params[:term], fields: ['name', 'description']}}, size: 100})
    render status: 200, json: items, only: [:id, :name, :description]
  end
end
