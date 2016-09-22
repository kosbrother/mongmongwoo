Pay2go.setup do |pay2go|
  pay2go.merchant_id = ENV["PAY2GO_MERCHANT_ID"]
  pay2go.hash_key    = ENV["PAY2GO_HASH_KEY"]
  pay2go.hash_iv     = ENV["PAY2GO_HASH_IV"]

  if Rails.env.production?
    pay2go.service_url = "https://api.pay2go.com/MPG/mpg_gateway"
  else
    pay2go.service_url = "https://capi.pay2go.com/MPG/mpg_gateway"
  end
end