module Admin::BannersHelper
  def bannerable_url(banner)
    case banner.bannerable_type
    when Banner::CATEGORY_RECORD
      category = banner.bannerable
      category_url(category)
    when Banner::Item_RECORD
      item = banner.bannerable
      category = item.categories.last
      category_item_url(category, item)
    end
  end
end