crumb :root do
  link "首頁", root_path
end

crumb :category do |category|
  link category.name, category_path(category)
  parent :root
end

crumb :item do |category, item|
  link item.name, category_item_path(category, item)
  parent :category, category
end
