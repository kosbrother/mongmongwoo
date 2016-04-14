namespace :images do

  desc "transer images from Server"
  task :photos  => :environment do
    Photo.all.each do |p|
      url = "http://106.185.34.142/storage/#{p.image.path}"
      p.remove_image
      p.remote_image_url = url
      p.save!
    end
  end
  task :items  => :environment do
    Item.all.each do |i|
      url = "http://106.185.34.142/storage/#{i.cover.path}"
      i.remove_cover
      i.remote_cover_url = url
      i.save!
    end
  end
  task :item_specs  => :environment do
    ItemSpec.all.each do |i|
      url = "http://106.185.34.142/storage/#{i.style_pic.path}"
      i.remove_style_pic
      i.remote_style_pic_url = url
      i.save!
    end
  end

end
