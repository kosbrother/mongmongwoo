CarrierWave.configure do |config|
  config.fog_provider = 'fog/google'                        # required
  config.fog_credentials = {
      provider:                         'Google',
      google_storage_access_key_id:     ENV["google_storage_access_key_id"],
      google_storage_secret_access_key: ENV["google_storage_secret_access_key"]
  }
  # Choose what kind of storage to use for this uploader:
  if Rails.env.production?
    # For google cloud storage
    config.storage :fog
    config.asset_host = ENV['production_asset_host']
    config.fog_directory = ENV['production_fog_directory']
  elsif Rails.env.staging?
    config.storage :fog
    config.asset_host = ENV['staging_asset_host']
    config.fog_directory = ENV['staging_fog_directory']
  elsif Rails.env.development?
    config.storage :file
  elsif Rails.env.test?
    config.storage :file
    config.enable_processing = false
  end

  ItemCoverUploader
  SpecPicUploader
  ImageUploader
  # Change store_dir depends on environment
  CarrierWave::Uploader::Base.descendants.each do |uploader|
    uploader.class_eval do
      if Rails.env.test?
        def cache_dir
          "#{Rails.root}/spec/support/uploads/tmp"
        end

        def store_dir
          "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end
      else
        def store_dir
          "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end
      end
    end
  end
end