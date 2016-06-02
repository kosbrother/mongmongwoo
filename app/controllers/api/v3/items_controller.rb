class Api::V3::ItemsController < ApiController
  def show
    item = Item.includes(:photos, :specs).find(params[:id])
    specs = item.specs.collect { |spec| spec if spec.status == "on_shelf" }
    spec_collection = specs.map do |spec|
      spec_hash = {}
      spec_hash[:id] = spec.id
      spec_hash[:style] = spec.style
      spec_hash[:pic] = spec.style_pic.url
      spec_hash
    end

    result = {}
    result[:id] = item.id
    result[:name] = item.name
    result[:price] = item.price
    result[:special_price] = item.special_price
    result[:cover] = item.cover.url
    result[:description] = item.description
    result[:status] = item.status
    result[:photos] = item.photos.collect { |photo| {image_url: photo.image.url} }
    result[:specs] = spec_collection

    render json: result
  end
end
