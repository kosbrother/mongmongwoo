class Banner < ActiveRecord::Base
  CATEGORY_RECORD = "Category"
  Item_RECORD = "Item"
  RECORD_TYPES = [CATEGORY_RECORD, Item_RECORD]
  RECORD_OPTONS = Banner::RECORD_TYPES.map { |record| [I18n.t(record), record] }

  belongs_to :bannerable, polymorphic: true

  scope :recent, -> { order(id: :DESC) }

  mount_uploader :image, OriginalPicUploader
end