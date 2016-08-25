module Admin::CategoriesHelper
  def parent_category_path(category)
    category.parent_category ? admin_category_path(category.parent_category) : admin_categories_path
  end

  def category_select_name(category)
    if category.parent_category
      "#{category.id} : #{category.name}(#{category.parent_category.name})"
    else
      "#{category.id} : #{category.name}"
    end
  end
end