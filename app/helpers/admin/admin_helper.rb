module Admin::AdminHelper
  def render_pagination(objects)
    if objects.total_pages > 1
       content_tag(:div, class: 'apple_pagination') do
         will_paginate objects, :container => false
       end
    end
  end

  def link_to_stock_index(active_boolean, link_name, options={taobao_supplier_id: TaobaoSupplier::DEAFAULT_SUPPLIER_ID, status: nil})
    supplier_id = options[:taobao_supplier_id]
    status = options[:status]
    content_tag(:li, class: "#{'active' if active_boolean}") do
      link_to link_name, admin_stocks_path(taobao_supplier_id: supplier_id, status: status)
    end
  end

  def link_to_edit_stock_spec(item_spec)
    if item_spec.stock_spec.present?
      link_to "編輯", edit_admin_stock_spec_path(item_spec.stock_spec), class: "btn btn-default"
    else
      "尚無庫存資料"
    end
  end
end