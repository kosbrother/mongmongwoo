# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
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
  process resize_to_fit: [600, 400]

  # 封面圖片尺寸
  version :thumb do
    process resize_to_fill: [150,100]
  end

  # Cover
  version :cover do
    process resize_to_fill: [450,300]
  end
end
