# encoding: utf-8

class SpecPicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if Rails.env.production?
    # For google cloud storage
    storage :fog
  elsif Rails.env.development?
    storage :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  # 預設圖片尺寸
  process resize_to_fit: [150, 150]
end