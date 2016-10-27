class NewsletterMailer < ApplicationMailer
  layout 'newsletter_mailer'

  def edm_newsletter
    @title = "活動電子報"
    @categories = Category.parent_categories
    @banner = Banner.order('RAND()').first
    @the_all_category = Category.find(Category::ALL_ID)
    @popular_items = @the_all_category.items.on_shelf.priority.limit(6)
    @the_new_category = Category.find(Category::NEW_ID)
    @newest_items = @the_new_category.items.on_shelf.order(created_at: :desc).limit(6)
    User.where.not(email: nil).find_in_batches do |user|
      mail(to: user.email, subject: "[萌萌屋] 萌萌屋#{@title}")
    end
  end
end