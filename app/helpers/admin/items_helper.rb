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
    link_to item.supplier_name, item.supplier_url, target: "_blank" rescue "沒有商家資料"
  end

  def li_item_status_link(taobao_supplier, status)
    content_tag(:li, '' , class: set_class_to_active(status)) do
      link_to t(Item.statuses.key(status)), admin_taobao_supplier_path(taobao_supplier, status: status)
    end
  end

  def link_to_stop_recommend(item, spec)
    if spec.is_stop_recommend
      link_to '恢復供貨', start_recommend_admin_item_item_spec_path(item, spec), remote: true, class: 'btn btn-success', method: :patch
    else
      link_to '停止供貨', stop_recommend_admin_item_item_spec_path(item, spec), remote: true, class: 'btn btn-danger', method: :patch
    end
  end
end