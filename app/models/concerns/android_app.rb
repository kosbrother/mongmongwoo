module AndroidApp
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  def app_index_url
    "android-app://com.kosbrother.mongmongwoo/https/www.mmwooo.com#{able_path}" if able_path
  end

  def able_path
    raise NotImplementedError
  end
end