class Promotion < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }

  has_many :item_promotions
  has_many :items, through: :item_promotions

  mount_uploader :image, OriginalPicUploader
end