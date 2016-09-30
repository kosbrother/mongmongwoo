module Admin::ItemsHelper
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

    image_tag(image_url)
  end

  def spec_photo(spec, photo_size=nil)
    if spec.style_pic.present?
      image_url = spec.style_pic.url
    else
      image_url = "http://placehold.it/150x150&text=No Pic"
    end

    photo_size ? image_tag(image_url, size: photo_size, :class => "thumbnail") : image_tag(image_url, :class => "thumbnail")
  end

  def link_to_supplier(item)
    if current_admin.manager?
      link_to item.supplier_name, admin_taobao_supplier_path(@item.taobao_supplier, status: Item.statuses[:on_shelf]), target: "_blank" rescue "沒有商家資料"
    else
      item.supplier_name
    end
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
    if current_admin.manager?
      link_to item_status_text(item), update_item_shelf_path(item), method: :patch, remote: true, class: btn_class_by_shelf_status(item.status)
    else
      content_tag(:span, item_status_text(item), class: label_class_by_shelf_status(item.status))
    end
  end

  def update_item_shelf_path(item)
    item.on_shelf? ? off_shelf_admin_item_path(item) : on_shelf_admin_item_path(item)
  end

  def btn_class_by_shelf_status(status)
    status == "on_shelf" ? "btn btn-success" : "btn btn-danger"
  end

  def label_class_by_shelf_status(status)
    status == "on_shelf" ? "label label-success" : "label label-danger"
  end

  def item_status_text(item)
    if item.ever_on_shelf == false
      "新商品未上架"
    else
      t(item.status)
    end
  end

  def item_initial_on_shelf_date(item)
    if item.ever_on_shelf
      display_date(item.created_at)
    else
      "未上架過"
    end
  end

  def link_to_item(item)
    link_to item.name, admin_item_path(item), target: "_blank"
  end

  def link_to_item_taobao(item)
    link_to '點擊連結', item.url, target: "_blank"
  end

  def li_link_to_items_index_with_params(active_boolean, link_name, options = {})
    options = {category_id: params[:category_id], status: params[:status], order: params[:order], ever_on_shelf: params[:ever_on_shelf], tag: params[:tag]}.merge(options)
    content_tag(:li, class: "#{'active' if active_boolean}") do
      link_to link_name, admin_items_path(category_id: options[:category_id], status: options[:status], order: options[:order], ever_on_shelf: options[:ever_on_shelf], tag: options[:tag])
    end
  end

  def category_checkbox(cb,f)
    if cb.object.id == 10 || cb.object.id == 11
      if f.object.new_record?
        cb.label(class: "checkbox-inline") {cb.check_box(class: "checkbox disabled", disabled: "disabled", checked:"checked") + cb.text}
      else
        cb.label(class: "checkbox-inline") {cb.check_box(class: "checkbox disabled", disabled: "disabled") + cb.text}
      end
    else
      cb.label(class: "checkbox-inline") {cb.check_box(class: "checkbox parent-category") + cb.text}
    end
  end

  def categories_checkox(f)
    f.collection_check_boxes :category_ids, Category.parent_categories, :id, :name do |cb|
      category_checkbox(cb,f)
    end
  end

  def subcategory_checkbox(f, parent_category_ids)
    f.collection_check_boxes :category_ids, Category.subcategories(parent_category_ids), :id, :name do |cb|
      cb.label(class: "checkbox-inline parent-#{cb.object.parent_id}") {cb.check_box(class: "checkbox") + cb.text}
    end
  end

  def subcategories_checkbox(f)
    if f.object.new_record?
      parent_category_ids = [Category::ALL_ID, Category::NEW_ID]
      subcategory_checkbox(f,parent_category_ids)
    else
      parent_category_ids = f.object.categories.map(&:id)
      subcategory_checkbox(f, parent_category_ids)
    end
  end

  def tag_checkbox(f)
    f.collection_check_boxes :tag_list, ActsAsTaggableOn::Tag.all, :name, :name do |cb|
      cb.label(class: "checkbox-inline") {cb.check_box(class: "checkbox") + cb.text}
    end
  end
end