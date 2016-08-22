class Banner < ActiveRecord::Base
  belongs_to :bannerable, polymorphic: true

  mount_uploader :image, OriginalPicUploader
end