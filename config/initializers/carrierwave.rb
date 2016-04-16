CarrierWave.configure do |config|
  config.fog_provider = 'fog/google'                        # required
  config.fog_credentials = {
      provider:                         'Google',
      google_storage_access_key_id:     ENV["google_storage_access_key_id"],
      google_storage_secret_access_key: ENV["google_storage_secret_access_key"]
  }
  config.asset_host = ENV['asset_host']
  config.fog_directory = ENV['fog_directory']

  # Choose what kind of storage to use for this uploader:
  if Rails.env.production?
    # For google cloud storage
    config.storage :fog
  elsif Rails.env.development?
    config.storage :file
  end
end
