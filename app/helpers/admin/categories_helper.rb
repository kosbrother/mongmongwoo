module Admin::CategoriesHelper
  def parent_category_path(category)
    category.parent_category ? admin_category_path(category.parent_category) : admin_categories_path
  end
end