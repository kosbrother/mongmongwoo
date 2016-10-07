class PagesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def index
    @banners = Banner.order(id: :desc)
    @category_with_items = @categories.map { |category| {category: category, items: category.items.on_shelf.priority.latest(12)} }
    set_meta_tags title: '首頁',
                  og: {
                    title:       "青年流行最前線",
                    type:        "website",
                    url:         root_url,
                    image:       view_context.asset_url(@banners.first.image_url),
                    description: "萌萌屋走在青年流行的前線, 為年輕人們提供一個快樂購物的管道, 想知道最近流行些什麼, 有什麼可愛的東東, 來萌萌屋就對了!"
                  }
  end

  def shop_infos
    @shop_infos = ShopInfo.all
  end
end
