class Category < ActiveRecord::Base
  ALL_ID = 10

  scope :recent, -> { order(id: :DESC) }
  scope :except_the_all_category, -> { where.not(id: 10) }
  scope :select_api_fields, -> { select(:id, :name, :image) }

  has_many :item_categories
  has_many :items, through: :item_categories

  mount_uploader :image, OriginalPicUploader

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [:name]
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize.to_s
  end
end