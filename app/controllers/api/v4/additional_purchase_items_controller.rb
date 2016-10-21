class Api::V4::AdditionalPurchaseItemsController < ApiController
  def index
    additional_purchase_items = AdditionalPurchaseItem.includes(:item).recent.as_json(
                                  only: [:id, :price],
                                  methods: [:price_reduction],
                                  include: { item: {only: [:id, :name, :price, :cover]} }
                                )
    additional_purchase_items.each do |additional_purchase_item|
      item = Item.find(additional_purchase_item["item"]["id"])
      additional_purchase_item["category_id"] = item.categories.where.not(id: [Category::ALL_ID, Category::NEW_ID]).last.id
    end

    render status: 200, json: {data: additional_purchase_items}
  end
end