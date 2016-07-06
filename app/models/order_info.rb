class OrderInfo < ActiveRecord::Base
  include InfoInspector
  after_update :check_store_id
  
  belongs_to :order
  belongs_to :store, :foreign_key => "ship_store_id"

  delegate :address, to: :store
  validates_presence_of :ship_name, :ship_phone, :ship_store_code, :ship_store_id, :ship_store_name, :ship_email

  def check_store_id
    correct_store = Store.find_by(store_code: self.ship_store_code)
    unless correct_store.id == self.ship_store_id
      self.update_columns(ship_store_id: correct_store.id, ship_store_name: correct_store.name)
    end
  end
end