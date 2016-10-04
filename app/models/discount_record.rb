class DiscountRecord < ActiveRecord::Base
  belongs_to :discountable, polymorphic: true
  belongs_to :campaign_rule, -> { with_deleted}
end