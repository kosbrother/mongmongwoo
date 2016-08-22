module Bannerable
  extend ActiveSupport::Concern

  included do
    has_many :banners, as: :bannerable, dependent: :destroy
  end
end