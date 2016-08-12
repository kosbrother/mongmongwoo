module Scheduleable
  extend ActiveSupport::Concern

  included do
    has_one :schedule, as: :scheduleable, dependent: :destroy
  end

  def schedule_type
    raise NotImplementedError
  end
end