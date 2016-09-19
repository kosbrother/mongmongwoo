module Admin::ShoppingPointsHelper
  def point_type_select_options
    options_for_select(ShoppingPoint.point_types.keys, "退貨金")
  end

  def shopping_point_campaign_id_select_options
    options_for_select(ShoppingPointCampaign.where(is_expired: false).map { |c| [c.title, c.id] })
  end

  def amount_from_order_items_price
    params[:order_items_price_amount].present? ? params[:order_items_price_amount] : 0
  end

  def link_to_previous_path
    if amount_from_order_items_price != 0
      previous_path = status_index_admin_orders_path(status: Order.statuses["退貨"])
    else
      previous_path = admin_users_path
    end

    link_to "返回前頁", previous_path, class: "btn btn-warning"
  end
end