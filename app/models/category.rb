class Category < ActiveRecord::Base
  include Bannerable

  ALL_ID = 10
  NEW_ID = 11

  validates_presence_of :name, :image

  has_many :item_categories, dependent: :destroy
  has_many :items, through: :item_categories
  belongs_to :parent_category, class_name: "Category", foreign_key: "parent_id"
  has_many :child_categories, class_name: "Category", foreign_key: "parent_id"

  default_scope { order(position: :DESC) }
  scope :except_the_all_category, -> { where.not(id: ALL_ID) }
  scope :select_api_fields, -> { select(:id, :name, :image) }
  scope :parent_categories, -> { where(parent_id: nil) }
  scope :subcategories, -> (parent_category_ids) { where(parent_id: parent_category_ids) }

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