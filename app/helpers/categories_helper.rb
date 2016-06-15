module CategoriesHelper
  def get_btn_class(order)
    if order == params['order']
      'btn btn-primary'
    else
      'btn btn-default'
    end
  end
end