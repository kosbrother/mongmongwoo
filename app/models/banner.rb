class Banner < ActiveRecord::Base
  include AndroidApp

  CATEGORY_RECORD = "Category"
  Item_RECORD = "Item"
  RECORD_TYPES = [CATEGORY_RECORD, Item_RECORD]
  RECORD_OPTONS = Banner::RECORD_TYPES.map { |record| [I18n.t(record), record] }

  belongs_to :bannerable, polymorphic: true

  scope :recent, -> { order(id: :DESC) }

  mount_uploader :image, OriginalPicUploader

  def able_path
    case bannerable_type
    when CATEGORY_RECORD
      category = bannerable
      category_path(category)
    when Item_RECORD
      item = bannerable
      category = item.categories.last
      category_item_path(category, item)
    end
  end
end