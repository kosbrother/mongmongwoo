class Photo < ActiveRecord::Base
  belongs_to :item

  scope :sort_by_position, -> { order(position: :ASC) }

  mount_uploader :image, ImageUploader
end