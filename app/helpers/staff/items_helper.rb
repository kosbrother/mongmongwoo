module Staff::ItemsHelper
  def staff_category_checkbox(cb,f)
    if cb.object.id == 10 || cb.object.id == 11
      cb.label(class: "checkbox-inline") {cb.check_box(class: "checkbox disabled", disabled: "disabled", checked:"checked") + cb.text}
    else
      cb.label(class: "checkbox-inline") {cb.check_box(class: "checkbox") + cb.text}
    end
  end

  def staff_categories_checkox(f)
    f.collection_check_boxes :category_ids, Category.all, :id, :name do |cb|
      staff_category_checkbox(cb,f)
    end
  end
end