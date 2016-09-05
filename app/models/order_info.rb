class OrderInfo < ActiveRecord::Base
  include InfoInspector
  
  belongs_to :order
  belongs_to :store, :foreign_key => "ship_store_id"

  delegate :address, :phone, to: :store

  validates_presence_of :ship_name, :ship_phone, :ship_email
  validates_presence_of :ship_store_code, :ship_store_id, :ship_store_name, if: :is_order_store_delivery?
  validates_presence_of :ship_address, if: :is_order_home_delivery?

  after_update :set_store_if_store_code_changed

  def store
    super || find_store
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

  def is_order_store_delivery?
    order.is_store_delivery?
  end

  def is_order_home_delivery?
    order.is_home_delivery?
  end
end