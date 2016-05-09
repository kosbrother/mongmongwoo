namespace :edit_order_item do
  task :add_source_item_id => :environment do
    OrderItem.all.each do |o_item|
      source_item = Item.find_by(name: o_item.item_name)
      if source_item && o_item.source_item_id.nil?
        if o_item.item_name == source_item.name
          o_item.update_columns(source_item_id: source_item.id)
        else
          next
        end
      end
    end
  end

  task :add_item_spec_id => :environment do
    OrderItem.all.each do |o_item|
      spec = o_item.item.specs.where(style: o_item.item_style)
      o_item.update_columns(item_spec_id: spec.first.id) if spec.present?
    end
  end
end