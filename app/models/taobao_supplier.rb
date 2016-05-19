class TaobaoSupplier < ActiveRecord::Base
  has_many :items

  delegate :count, to: :items
end