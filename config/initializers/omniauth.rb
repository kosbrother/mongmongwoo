Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
           callback_url:   "#{ENV['WEB_HOST']}/auth/facebook/callback", scope: 'public_profile', info_fields: 'email,name,gender'
end
