class Item < ActiveRecord::Base
  include Elasticsearch::Model
  index_name [Rails.env, self.base_class.to_s.pluralize.underscore].join('_')
  include Bannerable
  include AndroidApp

  mapping do
    indexes :name, type: 'string'
    indexes :description, type: 'string'
  end

  CNY_RATING = 5

  enum sort_params: { popular: "item_categories.position ASC", date: "items.created_at desc", price_asc: "price asc", price_desc: "price desc" }
  enum status: { on_shelf: 0, off_shelf: 1 }

  validates_presence_of :name, :price, :description
  validates_numericality_of :price, only_integer: true, greater_than: 0

  after_create :index_document, :track_price_if_changed
  after_update :update_document, :track_price_if_changed
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
  has_many :stock_specs
  has_many :price_records

  delegate :name, :url, to: :taobao_supplier, prefix: :supplier

  scope :recent, -> { order(id: :DESC) }
  scope :update_time, -> { order(updated_at: :DESC) }
  scope :priority, -> { order(Item.sort_params["popular"]) }
  scope :latest, ->(num){ order(created_at: :asc).limit(num) }
  scope :on_shelf, ->{ where(status: Item.statuses[:on_shelf]) }
  scope :off_shelf, ->{ where(status: Item.statuses[:off_shelf]) }
  scope :with_sold_items_sales_result, -> { joins(:order_items).select('items.*, SUM(order_items.item_quantity) as sales_amount, SUM(order_items.item_quantity * order_items.item_price) as subtotal').group("items.id").order('subtotal DESC') }

  acts_as_paranoid
  acts_as_taggable

  self.per_page = 15

  mount_uploader :cover, ItemCoverUploader

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def self.search_by_name_or_id(search_term)
    where("name LIKE :search_name OR id = :search_id", search_name: "%#{search_term}%", search_id: search_term).recent
  end

  def self.search_categories_new(category_id, num)
    joins(:categories).select("`items`.*, `categories`.`name` as category_name, `categories`.`id` as category_id").where(categories: {id: category_id}).order(created_at: :asc).limit(num)
  end

  def self.search_name_and_description(query)
    search(query: { multi_match: {query: query, fields: [ "name^3", "description" ]}})
  end

  def slug_candidates
    [:name]
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize.to_s
  end

  def intro_cover
    cover
  end

  def category_position(category)
    item_category(category).position
  end

  def item_category(category)
    item_categories.where(category_id: category.id)[0]
  end

  def final_price
    (special_price) ? special_price : price
  end

  def as_json(options = { })
    h = super(options)
    h[:final_price] = final_price
    h
  end

  def all_specs_off_shelf?
    specs.on_shelf.count == 0
  end

  def taobao_supplier_name
    taobao_supplier.present? ? taobao_supplier.name : '未登記'
  end

  def categories_name_except_all_and_new
    categories.where('categories.id > 11').pluck(:name).join(',')
  end

  def last_order_date
    order_items.last.created_at.strftime("%Y-%m-%d") if order_items.any?
  end

  def sales_within_30_days
    OrderItem.where(created_at: TimeSupport.within_days(30)).select('COALESCE(SUM(order_items.item_quantity), 0)as m_sales_amount, COALESCE(SUM(order_items.item_quantity * order_items.item_price), 0) as m_subtotal').find_by(source_item_id: id)
  end

  def sales_quantity
    order_items.sum(:item_quantity)
  end

  def sales_quantity_within_date(date)
    order_items.where(created_at: date).sum(:item_quantity)
  end

  def ntd_cost
    if cost
      (cost * Item::CNY_RATING).round(2)
    else
      "尚未建立資料"
    end
  end

  def able_path
    category_item_path(categories.parent_categories.last, self)
  end

  def track_price_if_changed
    if price_changed? || special_price_changed?
      pr = PriceRecord.new
      pr.item = self
      pr.changed_at = self.created_at
      pr.price = self.price
      pr.special_price = self.special_price
      pr.save
    end
  end

  def set_new_on_shelf_categories
    the_new_category = Category.find(Category::NEW_ID)
    categories << the_new_category if categories.exclude?(the_new_category)
    child_category = the_new_category.child_categories.find_or_initialize_by(name: "#{created_at.year}年#{created_at.month}月")
    if child_category.new_record?
      child_category.position = Category.where(parent_id: Category::NEW_ID).maximum("position") + 1 unless Category.where(parent_id: Category::NEW_ID).blank?
      child_category.image = Rails.root.join("app/assets/images/icons/months/month_#{created_at.month}.png").open
      child_category.save
    end
    categories << child_category if categories.exclude?(child_category)
  end

  def remove_existed_new_on_shelf_categories
    the_new_categories = categories.where("category_id = :id OR parent_id = :id", id: Category::NEW_ID)
    categories.delete(the_new_categories)
    the_new_categories.each{|category| category.destroy if category.items.on_shelf.blank?}
  end

  private

  def as_indexed_json(options={})
   {"name" => name, "description" => description }
  end

  def index_document
    __elasticsearch__.index_document if status == "on_shelf"
  end

  def update_document
    if status == "on_shelf"
      __elasticsearch__.index_document if !document_exist?
      __elasticsearch__.update_document if document_exist?
    elsif status == "off_shelf"
      __elasticsearch__.delete_document if document_exist?
    end
  end

  def delete_document
    __elasticsearch__.delete_document if document_exist?
  end

  def document_exist?
    __elasticsearch__.client.exists({"index": Item.index_name, "type": "item", "id": id})
  end
end
