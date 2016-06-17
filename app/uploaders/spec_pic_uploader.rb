# encoding: utf-8

class SpecPicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # 預設圖片尺寸
  process resize_to_fit: [150, 150]

  version :web do
    process resize_to_fit: [300, 300]
  end
end