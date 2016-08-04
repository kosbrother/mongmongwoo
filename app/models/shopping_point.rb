class ShoppingPoint < ActiveRecord::Base
  enum point_types: { "退訂入帳" => 0, "消費支出" => 1, "贈金入帳" => 2 }

  belongs_to :user
end