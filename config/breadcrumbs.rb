crumb :root do
  link "首頁", root_path
end

crumb :category do |category|
  link category.name, category_path
  parent :root
end