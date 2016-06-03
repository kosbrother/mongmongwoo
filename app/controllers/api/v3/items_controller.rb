class Api::V3::ItemsController < ApiController
  def show
    item = Item.includes(:photos).find(params[:id])
    specs = item.specs.on_shelf.select(:id,:style,:style_pic)
    spec_collection = specs.map do |spec|
      spec_hash = {}
      spec_hash[:id] = spec.id
      spec_hash[:style] = spec.style
      spec_hash[:style_pic] = spec.style_pic.url
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
