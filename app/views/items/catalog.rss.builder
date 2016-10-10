#encoding: UTF-8
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", "xmlns:g" => "http://base.google.com/ns/1.0" do
  xml.channel do
    xml.title "萌萌屋 - 走在青年流行前線"
    xml.link "https://www.mmwooo.com/"
    xml.description "Product Feeds"

    for item in @items
      xml.item do
        xml.tag!("g:id", item.id)
        xml.tag!("g:title", item.name)
        xml.tag!("applink", nil, property: "android_url", content: item.app_index_url)
        xml.tag!("applink", nil, property: "android_package", content: "com.kosbrother.mongmongwoo")
        xml.tag!("applink", nil, property: "android_app_name", content: "萌萌屋 - 走在青年流行前線")
        xml.tag!("g:description", strip_tags(item.description).gsub("\r\n\r\n"," "))
        item.categories.each do |category|
          xml.tag!("g:google_product_category", category.name)
        end
        xml.tag!("g:link", category_item_url(item.categories.parent_categories.last, item, protocol: 'https'))
        xml.tag!("g:image_link", item.specs[0].style_pic.url)
        xml.tag!("g:condition", "new")
        xml.tag!("g:availability", (item.status == "on_shelf") ? "in stock" : "out of stock")
        xml.tag!("g:price", "#{item.price} TWD")
        xml.tag!("g:brand", "萌萌屋 - 走在青年流行前線")
        xml.tag!("g:item_group_id", "DB_GROUP_1")
        xml.tag!("g:shipping") do |t|
          t.tag!("g:country", "TW")
          t.tag!("g:service", "Standard")
          t.tag!("g:price", "90 TWD")
        end
        xml.tag!("g:custom_label_0", "Made in China")
      end
    end
  end
end