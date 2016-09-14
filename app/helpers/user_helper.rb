module UserHelper
  def current_active_class(link_path)
    request.path == link_path ? '-active' : nil
  end
end
