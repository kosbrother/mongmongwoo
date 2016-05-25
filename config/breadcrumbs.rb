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

crumb :orders do
  link "我的訂單", orders_path
  parent :root
end

crumb :order_detail do |order|
  link "訂單明細", order_path(order)
  parent :orders
end

crumb :favorites do
  link "我的收藏", favorite_items_path
  parent :root
end