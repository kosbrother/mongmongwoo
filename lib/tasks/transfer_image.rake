namespace :images do

  desc "transer images from Server"
  task :photos  => :environment do
    Photo.all.each do |p|
      unless file_exist?(p.image.url)        
        url = "http://106.185.34.142/storage/#{p.image.path}"
        p.remove_image
        p.remote_image_url = url
        p.save!
        puts "Photo id: #{p.id} saved!"
      end
    end
  end

  task :items  => :environment do
    Item.all.each do |i|
      unless file_exist?(i.cover.url)
        url = "http://106.185.34.142/storage/#{i.cover.path}"
        i.remove_cover
        i.remote_cover_url = url
        i.save!
        puts "Item id: #{i.id} saved!"
      end
    end
  end

  task :item_specs  => :environment do
    ItemSpec.all.each do |i|
      unless file_exist?(i.style_pic.url)
        url = "http://106.185.34.142/storage/#{i.style_pic.path}"
        i.remove_style_pic
        i.remote_style_pic_url = url
        i.save!
        puts "ItemSpec id: #{i.id} saved!"
      end
    end
  end

  def file_exist?(url)
    begin
      open(url)
    rescue
      result = false
    else
      result = true
    end
    result
  end
end
