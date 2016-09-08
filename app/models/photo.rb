class Photo < ActiveRecord::Base
  default_scope { order(position: :DESC) }

  belongs_to :item

  mount_uploader :image, ImageUploader
end