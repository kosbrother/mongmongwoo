class OrderInfo < ActiveRecord::Base
  belongs_to :order
  belongs_to :store, :foreign_key => "ship_store_id"

  delegate :address, to: :store
  validates_presence_of :ship_name, :ship_phone, :ship_store_code, :ship_store_id, :ship_store_name, :ship_email
end
