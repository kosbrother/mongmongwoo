# == Schema Information
#
# Table name: items
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  price       :integer          not null
#  slug        :string(255)
#  status      :integer          default(0)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text(65535)
#  cover       :string(255)
#  position    :integer          default(1)
#  url         :string(255)
#

class Item < ActiveRecord::Base
  scope :recent, lambda { order(id: :DESC) }
  scope :update_time, lambda { order(updated_at: :DESC) }
  scope :priority, lambda { order("item_categories.position ASC") }
  scope :category_new, ->(num){ order(created_at: :asc).limit(num) }

  enum status: { on_shelf: 0, off_shelf: 1 }

  acts_as_paranoid

  self.per_page = 15

  has_many :photos, dependent: :destroy
  has_many :item_categories
  has_many :categories, through: :item_categories
  has_many :specs, class_name: "ItemSpec", dependent: :destroy
  has_many :notifications, dependent: :destroy
  belongs_to :taobao_supplier
  has_many :favorite_items
  has_many :favorited_by, through: :favorite_items, source: :user

  delegate :name, :url, to: :taobao_supplier, prefix: :supplier

  validates_presence_of :name, :price, :description
  validates_numericality_of :price, only_integer: true, greater_than: 0

  mount_uploader :cover, ItemCoverUploader

  # 封面圖
  def intro_cover
    cover
  end

  def self.search_by_name(search_term)
    return [] if search_term.blank?
    where("name LIKE ?", "%#{search_term}%").recent
  end

  def category_position(category)
    item_category(category).position
  end

  def item_category(category)
    item_categories.where(category_id: category.id)[0]
  end

  def self.search_categories_new(category_id, num)
    self.joins(:categories).select("`items`.*, `categories`.`name` as category_name, `categories`.`id` as category_id").where(categories: {id: category_id}).order(created_at: :asc).limit(num)
  end

end