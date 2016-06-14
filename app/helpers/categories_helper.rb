module CategoriesHelper
  def get_btn_class(order)
    if order == params['order']
      'btn btn-primary'
    else
      'btn btn-default'
    end
  end
  
  def category_photo(category)
    if category.image_url.present?
      image_url = category.image_url
    else
      image_url = "http://placehold.it/150x150&text=No Pic"
    end

    image_tag(image_url, size: "120x120")
  end
end