module ShoppingPointHelper
  def shopping_point_campaign_status_text(is_expired, is_collect)
    if is_collect
      'collect'
    elsif is_expired
      'un-collect'
    else
      'processing'
    end
  end
end