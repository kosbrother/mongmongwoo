class Category < ActiveRecord::Base
  ALL_ID = 10
  PARENT_IDS = [10, 11, 12, 13, 14, 16]

  validates_presence_of :name, :image

  has_many :item_categories
  has_many :items, through: :item_categories
  belongs_to :parent_category, class_name: "Category", foreign_key: "parent_id"
  has_many :child_categories, class_name: "Category", foreign_key: "parent_id"

  scope :main_parents, -> { where(id: PARENT_IDS) }
  scope :recent, -> { order(id: :DESC) }
  scope :except_the_all_category, -> { where.not(id: 10) }
  scope :select_api_fields, -> { select(:id, :name, :image) }

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