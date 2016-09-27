module Admin::ItemSpecsHelper
  def link_to_update_item_spec_status(item_spec)
    if current_admin.manager?
      link_to t(item_spec.status), update_item_spec_shelf_path(item_spec), method: :patch, remote: true, class: btn_class_by_shelf_status(item_spec.status)
    else
      content_tag(:span, t(item_spec.status), class: label_class_by_shelf_status(item_spec.status))
    end
  end

  def update_item_spec_shelf_path(item_spec)
    item_spec.on_shelf? ? off_shelf_admin_item_item_spec_path(item_spec.item, item_spec) : on_shelf_admin_item_item_spec_path(item_spec.item, item_spec)
  end
end