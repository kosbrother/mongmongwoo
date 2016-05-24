module UserHelper
  def current_active_class(type, path)
    type == path ? '-active' : ''
  end
end
