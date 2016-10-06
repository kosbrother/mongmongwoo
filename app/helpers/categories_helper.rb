module CategoriesHelper
  def get_btn_class(order)
    if order == params['order']
      'btn btn-primary'
    else
      'btn btn-default'
    end
  end

  def set_active_by_condition(child_categories, current_category, category_group, index)
    if child_categories.include?(current_category)
      'active' if category_group.include?(current_category)
    else
      'active' if index == 0
    end
  end

  def month_sub_category_link_text(sub_category)
    mobile? ? sub_category.name.split('年')[1] : sub_category.name
  end
end