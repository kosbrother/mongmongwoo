namespace :shopping_points do
  task :valid_until => :environment do
    ShoppingPoint.find_each do |shopping_point|
      if shopping_point.valid_until && shopping_point.valid_until <= Time.current
        shopping_point.update_column(:is_valid, false)
      end
    end
  end
end