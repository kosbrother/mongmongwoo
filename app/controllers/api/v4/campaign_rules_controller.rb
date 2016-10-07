class Api::V4::CampaignRulesController < ApiController
  def index
    data = CampaignRule.valid.as_json(only: [:id, :title, :description, :created_at, :valid_until, :list_icon], methods: :app_index_url)
    data.each do|item|
      item['icon'] = item.delete 'list_icon'
    end

    render status: 200, json: { data: data }
  end

  def show
    campaign_rule = CampaignRule.find(params[:id])
    data = campaign_rule.as_json(only: :banner_cover)
    data['image'] = data.delete 'banner_cover'
    items = campaign_rule.items.as_json(only: [:id, :name, :price, :special_price, :cover, :slug], methods: [:discount_icon], include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] }})
    items.each{|item| item["specs"] = item.delete "on_shelf_specs"}
    data = data.merge(items: items)

    render status: 200, json: { data: data }
  end
end