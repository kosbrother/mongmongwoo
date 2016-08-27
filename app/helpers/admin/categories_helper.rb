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

  def parent_and_child_categories_name(categories)
    name_list = categories.map do |category|
      if category.parent_id
        "#{category.name}(#{category.parent_category.name})"
      elsif (category.id == Category::ALL_ID) || (category.id == Category::NEW_ID)
        "#{category.name}"
      end
    end

    name_list.compact.join(', ')
  end
end