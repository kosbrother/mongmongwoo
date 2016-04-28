require 'net/http'
require 'nokogiri'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

namespace :seven_store do
  task :get_store_all => :environment do
    County.where("store_type = ?", "4").each do |county|
      county.towns.each do |town|
        town.roads.each do |road|
          url = URI.parse("https://emap.pcsc.com.tw/EMapSDK.aspx")
          option = {
                    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.86 Safari/537.36',
                    'Cookie' => 'ASP.NET_SessionId=4jsarnxw45hhf0rguy4y50i1; gsScrollPos=0',
                    'X-Requested-With'=>'XMLHttpRequest',
                    'commandid'=>'SearchStore',
                    'city' => county.name,
                    'town' => town.name,
                    'roadname' => road.name
                  }
          resp, data = Net::HTTP.post_form(url, option)
          resp_page = Nokogiri::HTML(resp.body)
          resp_page.css("geoposition").each do |element|
            if town.stores.find_by(store_code: element.css("poiid").children.to_s.strip)
              next
            else            
              store = Store.new
              store.county_id = county.id
              store.town_id = town.id
              store.store_type = 4
              store.store_code = element.css("poiid").children.to_s.strip
              store.name = "7-11" + element.css("poiname").children.to_s + "門市"
              store.phone = element.css("telno").children.to_s.strip
              store.address = element.css("address").children.to_s
              store.road = road
              store.save!
              
              puts store.road.name if store.road
              puts store.store_code
              puts store.name
              puts store.phone
              puts store.address
            end
          end
        end
      end
    end
  end

  task :get_road_all => :environment do
    County.where("store_type = ?", "4").each do |county|
      county.towns.each do |town|
        url = URI.parse("https://emap.pcsc.com.tw/EMapSDK.aspx")
        option = {
                  'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.86 Safari/537.36',
                  'Cookie' => 'ASP.NET_SessionId=4jsarnxw45hhf0rguy4y50i1; gsScrollPos=0',
                  'X-Requested-With'=>'XMLHttpRequest',
                  'commandid'=>'SearchRoad',
                  'city' => county.name,
                  'town' => town.name,
                }
        resp, data = Net::HTTP.post_form(url, option)
        resp_page = Nokogiri::XML(resp.body)
        resp_page.css("RoadName").each do |element|
          result_road_name = element.css("rd_name_1").children.to_s + element.css("section_1").children.to_s
          if town.roads.find_by(name: result_road_name)
            next
          else
            road = Road.new
            road.town_id = town.id
            road.name = result_road_name
            road.store_type = 4
            road.save!
            puts road.name
          end
        end
      end
    end
  end

  task :get_town_all => :environment do
    County.where("store_type = ?", "4").each do |county|
      url = URI.parse("https://emap.pcsc.com.tw/EMapSDK.aspx")    
      option = {
                'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.86 Safari/537.36',
                'Cookie' => 'ASP.NET_SessionId=zuyd04eafmaayfwu1klvmxl1',
                'X-Requested-With'=>'XMLHttpRequest',
                'commandid'=>'GetTown',
                'cityid'=> county.cityid,
              }
      resp, data = Net::HTTP.post_form(url, option)
      resp_page = Nokogiri::HTML(resp.body)
      puts resp_page.css("geoposition")
      resp_page.css("geoposition").each do |position|
        if county.towns.find_by(name: position.css("townname").children.to_s)
          next
        else
          town = Town.new
          town.county_id = county.id
          town.store_type = 4
          town.name = position.css("townname").children.to_s
          town.save!
          puts town.name
        end
      end
    end
  end

  task :get_county_all => :environment do
    Rake::Task['db:seed'].invoke unless County.where("store_type = ?", "4").any?
  end
end