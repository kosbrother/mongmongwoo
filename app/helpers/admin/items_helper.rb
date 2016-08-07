module Admin::ItemsHelper
  def item_title
    action_name == "new" ? "新增商品" : "編輯商品"
  end

  def item_icon(photo)
    if photo.present?
      image_url = photo.icon.url
    else
      image_url = "http://placehold.it/150x100&text=No Pic"      
    end
    
    image_tag(image_url, class: "thumbnail")
  end

  def item_cover(photo)
    if photo.present?
      image_url = photo.url
    else
      image_url = "http://placehold.it/450x300&text=No Pic"      
    end
    
    image_tag(image_url, class: "thumbnail")
  end

  def item_photo(photo, size=nil)
    if photo.present?
      if size.present?
        image_url = photo.image.send(size).url
      else        
        image_url = photo.image.url
      end
    else
      case size
      when :cover
        volume = "450x300"
      when :thumb
        volume = "150x100"
      else
        volume = "600x400"
      end

      image_url = "http://placehold.it/#{volume}&text=No Pic"
    end

    image_tag(image_url, :class => "thumbnail")
  end

  def spec_photo(spec, photo_size=nil)
    if spec.style_pic.present?
      image_url = spec.style_pic.url
    else
      image_url = "http://placehold.it/150x150&text=No Pic"
    end

    photo_size ? image_tag(image_url, size: photo_size, :class => "thumbnail") : image_tag(image_url, :class => "thumbnail")
  end

  def show_item_stock(amount)
    amount == 0 ? "無庫存" : amount
  end

  def item_status(status)
    case status
    when "on_shelf"
      return "上架中"
    when "off_shelf"
      return "已下架" 
    end
  end

  def spec_status(status)
    case status
    when "on_shelf"
      return "上架中"
    when "off_shelf"
      return "已下架" 
    end
  end

  def update_shelf_path(item)
    item.on_shelf? ? off_shelf_admin_item_path(item) : on_shelf_admin_item_path(item)
  end

  def link_to_supplier(item)
    link_to item.supplier_name, admin_taobao_supplier_path(@item.taobao_supplier, status: Item.statuses[:on_shelf]), target: "_blank" rescue "沒有商家資料"
  end

  def li_item_status_link(taobao_supplier, status)
    content_tag(:li, '' , class: set_class_to_active(status)) do
      link_to t(Item.statuses.key(status)), admin_taobao_supplier_path(taobao_supplier, status: status)
    end
  end

  def link_to_stop_recommend(item, spec)
    if spec.is_stop_recommend
      link_to '否', start_recommend_admin_item_item_spec_path(item, spec), remote: true, class: 'btn btn-danger', method: :patch
    else
      link_to '是', stop_recommend_admin_item_item_spec_path(item, spec), remote: true, class: 'btn btn-success', method: :patch
    end
  end

  def link_to_update_item_status(item)
    link_to item_status(item.status), update_shelf_path(item), method: :patch, remote: true, class: status_button_class(item.status)
  end

  def link_to_update_item_spec(item_spec)
    if item_spec.status == "off_shelf"
      link_to "已下架", on_shelf_admin_item_item_spec_path(item_spec.item, item_spec), method: :patch, remote: true, class: status_button_class(item_spec.status)
    else
      link_to "上架中", off_shelf_admin_item_item_spec_path(item_spec.item, item_spec), method: :patch, remote: true, class: status_button_class(item_spec.status)
    end
  end

  def status_button_class(status)
    (status == "on_shelf") ? "btn btn-success" : "btn btn-danger"
  end

  def link_to_item(item)
    link_to item.name, admin_item_path(item), target: "_blank"
  end

  def link_to_item_taobao(item)
    link_to '點擊連結', item.url, target: "_blank"
  end
end