class Item < ActiveRecord::Base
  include Elasticsearch::Model
  index_name [Rails.env, self.base_class.to_s.pluralize.underscore].join('_')

  mapping do
    indexes :name, type: 'string'
    indexes :description, type: 'string'
  end

  CNY_RATING = 5

  enum sort_params: { price_desc: "price desc", price_asc: "price asc", popular: "item_categories.position ASC", date: "items.created_at desc" }
  enum status: { on_shelf: 0, off_shelf: 1 }

  validates_presence_of :name, :price, :description
  validates_numericality_of :price, only_integer: true, greater_than: 0

  after_create :index_document
  after_update :update_document
  after_destroy :delete_document

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
  has_many :order_items, foreign_key: :source_item_id
  has_one :stock

  delegate :name, :url, to: :taobao_supplier, prefix: :supplier

  scope :recent, -> { order(id: :DESC) }
  scope :update_time, -> { order(updated_at: :DESC) }
  scope :priority, -> { order("item_categories.position ASC") }
  scope :latest, ->(num){ order(created_at: :asc).limit(num) }
  scope :on_shelf, ->{ where(status: Item.statuses[:on_shelf]) }
  scope :off_shelf, ->{ where(status: Item.statuses[:off_shelf]) }
  scope :with_sold_items_sales_report, -> { joins(:order_items).select('items.*, SUM(order_items.item_quantity) as sales_amount, SUM(order_items.item_quantity * order_items.item_price) as subtotal').group("items.id").order('subtotal DESC') }
  scope :with_all_items_sales_report, -> { joins("LEFT JOIN `order_items` ON order_items.source_item_id = items.id").select('items.*, SUM(order_items.item_quantity) as sales_amount, SUM(order_items.item_quantity * order_items.item_price) as subtotal').group("items.id") }

  acts_as_paranoid

  self.per_page = 15

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

  def self.search_name_and_description(query)
    search(query: { multi_match: {query: query, fields: [ "name^3", "description" ]}})
  end

  def all_specs_off_shelf?
    count = self.specs.on_shelf.count
    count == 0 ? true : false
  end

  def taobao_supplier_name
    if self.taobao_supplier.present?
      self.taobao_supplier.name
    else
      '未登記'
    end
  end

  def categories_name_except_all_and_new
    categories.where('categories.id > 11').pluck(:name).join(',')
  end

  def last_order_date
    order_items.last.created_at.strftime("%Y-%m-%d") if order_items.any?
  end

  private

  def as_indexed_json(options={})
   {"name" => name, "description" => description }
  end

  def index_document
    __elasticsearch__.index_document if status == "on_shelf"
  end

  def update_document
    __elasticsearch__.update_document if status == "on_shelf" && document_exist?
    __elasticsearch__.delete_document if status == "off_shelf" && document_exist?
  end

  def delete_document
    __elasticsearch__.delete_document if document_exist?
  end

  def document_exist?
    __elasticsearch__.client.exists({"index": Item.index_name, "type": "item", "id": id})
  end
end
