class Item < ActiveRecord::Base
  include Elasticsearch::Model
  index_name [Rails.env, self.base_class.to_s.pluralize.underscore].join('_')

  mapping do
    indexes :name, type: 'string'
    indexes :description, type: 'string'
  end

  after_create :index_document
  after_update :update_document
  after_destroy :delete_document

  scope :recent, -> { order(id: :DESC) }
  scope :update_time, -> { order(updated_at: :DESC) }
  scope :priority, -> { order("item_categories.position ASC") }
  scope :latest, ->(num){ order(created_at: :asc).limit(num) }
  scope :on_shelf, ->{ where(status: 0) }

  enum sort_params: { price_desc: "price desc", price_asc: "price asc", popular: "item_categories.position ASC", date: "items.created_at desc" }
  enum status: { on_shelf: 0, off_shelf: 1 }

  CNY_RATING = 5

  acts_as_paranoid

  self.per_page = 15

  has_many :photos, dependent: :destroy
  has_many :item_categories
  has_many :categories, through: :item_categories
  has_many :specs, class_name: "ItemSpec", dependent: :destroy
  has_many :on_shelf_specs, ->{ where(status: ItemSpec.statuses["on_shelf"]) }, class_name: "ItemSpec"
  has_many :notifications, dependent: :destroy
  belongs_to :taobao_supplier
  has_many :favorite_items
  has_many :favorited_by, through: :favorite_items, source: :user
  has_many :item_promotions
  has_many :promotions, through: :item_promotions
  has_one :stock
  has_many :shipping_items

  delegate :name, :url, to: :taobao_supplier, prefix: :supplier

  validates_presence_of :name, :price, :description
  validates_numericality_of :price, only_integer: true, greater_than: 0

  mount_uploader :cover, ItemCoverUploader

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [:name]
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize.to_s
  end

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

  def final_price
    (special_price) ? special_price : price
  end

  def as_json(options = { })
    h = super(options)
    h[:final_price] = final_price
    h
  end

  def as_indexed_json(options={})
   {"name" => name, "description" => description }
  end

  def index_document
    __elasticsearch__.index_document if status == "on_shelf"
  end

  def update_document
    __elasticsearch__.update_document if status == "on_shelf"
    __elasticsearch__.delete_document if status == "off_shelf"
  end

  def delete_document
    __elasticsearch__.delete_document
  end

  def self.search_name_and_description(query)
    search(query: { multi_match: {query: query, fields: [ "name^3", "description" ]}})
  end

  def all_specs_off_shelf?
    specs_statuses = self.specs.map(&:status)
    !(specs_statuses.include?("on_shelf")) ? true : false
  end
end
