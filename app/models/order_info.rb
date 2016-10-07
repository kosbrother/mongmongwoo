class OrderInfo < ActiveRecord::Base
  include InfoInspector

  belongs_to :order
  belongs_to :store, :foreign_key => "ship_store_id"

  delegate :address, :phone, to: :store

  validates_presence_of :ship_name, :ship_phone, :ship_email
  validates_presence_of :ship_store_code, :ship_store_id, :ship_store_name, if: :is_order_store_delivery?
  validates_presence_of :ship_address, if: :is_home_delivery?
  validates_format_of :ship_name, with: /\p{Han}/, message: "請輸入中文姓名"

  after_update :set_store_if_store_code_changed

  def store
    super || find_store
  end

  def is_order_store_delivery?
    order.store_delivery?
  end

  def is_home_delivery?
    order.home_delivery? || order.home_delivery_by_credit_card?
  end

  private

  def set_store_if_store_code_changed
    if ship_store_code_changed?
      store = Store.find_by(store_code: ship_store_code)
      self.update_columns(ship_store_id: store.id, ship_store_name: store.name)
    end
  end

  def find_store
    Store.with_deleted.find(self.ship_store_id)
  end
end