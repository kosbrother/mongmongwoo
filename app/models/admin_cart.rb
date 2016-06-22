class AdminCart < ActiveRecord::Base
  has_many :admin_cart_items
  belongs_to :taobao_supplier
end
