class Cart < ActiveRecord::Base

  has_many :cart_items, dependent: :destroy
  belongs_to :user

  def total
    cart_items.reduce(0) do |sum, current|
      sum + current.subtotal.to_i
    end
  end

end
