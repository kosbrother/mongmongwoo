class PagesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def index
    @banners = Banner.order(id: :desc)
    @category_with_items = @categories.map { |category| {category: category, items: category.items.on_shelf.priority.latest(12)} }
    set_meta_tags title: '首頁',
                  description: '萌萌屋是學生網購天堂，筆袋、耳機、禮品、飾品、水瓶、餐具、包包、雜貨、日韓流行、保養、貼紙、紙膠帶、文具、等校園生活萌物，APP購物現貨不必等。萌萌屋提供年輕女生可愛新奇又特別的小東西，周周新品活動促銷。療癒搞怪都在萌萌屋。',
                  keywords: Category.except_the_all_category.select("name").map(&:name),
                  og: {
                    title:       "萌萌屋 | 校園生活補給站",
                    type:        "website",
                    url:         root_url(protocol: 'https'),
                    description: "萌萌屋是學生網購天堂，筆袋、耳機、禮品、飾品、水瓶、餐具、包包、雜貨、日韓流行、保養、貼紙、紙膠帶、文具、等校園生活萌物，APP購物現貨不必等。萌萌屋提供年輕女生可愛新奇又特別的小東西，周周新品活動促銷。療癒搞怪都在萌萌屋。"
                  }
  end

  def shop_infos
    @shop_infos = ShopInfo.all
  end
end
