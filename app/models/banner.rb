class Banner < ActiveRecord::Base
  include AndroidApp

  BANNER_TYPES = [nil, Category.name, Item.name]

  belongs_to :bannerable, polymorphic: true

  scope :recent, -> { order(id: :DESC) }

  mount_uploader :image, OriginalPicUploader

  def able_path
    case bannerable_type
    when Category.name
      category = bannerable
      category_path(category)
    when Item.name
      item = bannerable
      category = item.categories.last
      category_item_path(category, item)
    end
  end
end