module Admin::AdminHelper
  def render_pagination(objects)
    if objects.total_pages > 1
       content_tag(:div, class: 'apple_pagination') do
         will_paginate objects, :container => false
       end
    end
  end
end