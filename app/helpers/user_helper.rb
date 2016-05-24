module UserHelper
  def current_active_class(current_path, link_path)
    current_path == link_path ? '-active' : ''
  end
end
