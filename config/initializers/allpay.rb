AllpayGoodsService.merchant_id = ENV['MERCHANT_ID']
AllpayGoodsService.hash_key = ENV['HASH_KEY']
AllpayGoodsService.hash_iv = ENV['HASH_IV']

Logistics_Status = YAML.load_file("#{Rails.root.to_s}/config/allpay_logistics_status.yml")