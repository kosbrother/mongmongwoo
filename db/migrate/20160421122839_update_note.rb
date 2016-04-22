class UpdateNote < ActiveRecord::Migration
  def up
    Order.all.each do |o|
      if o.note.nil?
        o.update_attribute :note, ""
      end
    end
  end
end
