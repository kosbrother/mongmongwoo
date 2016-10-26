class NewsletterMailer < ApplicationMailer
  layout 'newsletter_mailer'

  def edm_newsletter
    @title = "活動電子報"
    @categories = Category.parent_categories
    @the_all_category = Category.find(Category::ALL_ID)
    @popular_items = Item.on_shelf.joins(:item_categories).where('item_categories.category_id = :category_id', category_id: Category::ALL_ID).priority.limit(6)
    @the_new_category = Category.find(Category::NEW_ID)
    @newest_items = Item.on_shelf.joins(:item_categories).where('item_categories.category_id = :category_id', category_id: Category::NEW_ID).order(created_at: :desc).limit(6)
    User.where.not(email: nil).find_in_batches do |user|
      mail(to: user.email, subject: "[萌萌屋] 萌萌屋#{@title}")
    end
  end
end