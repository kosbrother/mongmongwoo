crumb :root do
  link "首頁", root_path
end

crumb :category do |category|
  link category.name, category_path(category)
  parent :root
end

crumb :child_category do |child_category|
  link child_category.name, category_path(child_category)
  parent :category, child_category.parent_category
end

crumb :item do |category, item|
  link item.name, category_item_path(category, item)
  parent :category, category
end

crumb :orders do
  link "我的訂單", orders_path
  parent :root
end

crumb :my_messages do
  link "我的通知", my_messages_path
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

crumb :wish_lists do
  link "補貨清單", wish_lists_path
  parent :root
end

crumb :shopping_point_campaigns do
  link "購物金活動", shopping_point_campaigns_path
  parent :my_shopping_point
end

crumb :my_shopping_point do
  link "我的購物金", shopping_points_path
  parent :root
end

crumb :shop_infos do
  link "購物明細", shop_infos_path
  parent :root
end

crumb :search_result do
  link "搜尋結果",  search_items_path
  parent :root
end