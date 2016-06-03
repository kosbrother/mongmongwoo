# encoding: utf-8

class SpecPicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # 預設圖片尺寸
  process resize_to_fit: [150, 150]
end