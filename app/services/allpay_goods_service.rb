class AllpayGoodsService

  attr_reader :fields

  class << self
    attr_accessor :merchant_id, :hash_key, :hash_iv
  end

  def initialize(params={})
    @fields = {}
    add_default_fields
    add_fields(params)
  end

  def create_order
    encrypted_data
    url = URI.parse("https://logistics.allpay.com.tw/Express/Create")
    resp, data = Net::HTTP.post_form(url, @fields.sort.to_h)
    puts resp.body
    
    if resp.body.start_with? '0'
      return false
    else
      return true
    end
  end

  def add_default_fields(params={})
    add_field("MerchantID", AllpayGoodsService.merchant_id)
    add_field 'MerchantTradeDate', Time.now
    add_field("LogisticsType", params["LogisticsType"] || default_params["LogisticsType"])
    add_field("LogisticsSubType", params["LogisticsSubType"] || default_params["LogisticsSubType"])
    add_field("IsCollection", params["IsCollection"] || default_params["IsCollection"])
  end

  # LogisticsType　CVS:超商取貨　Home:宅配
  # LogisticsSubType:   FAMI:全家
  #                     UNIMART:統一超商
  #                     FAMIC2C:全家店到店
  #                     UNIMARTC2C:統一超
  #                     商交貨便
  #                     TCAT:黑貓
  #                     ECAN:宅配通
  # IsCollection 代收付款 Y, N

  def default_params
    {"LogisticsType" => "CVS","LogisticsSubType" => "UNIMART","IsCollection" => "Y"}
  end

  def add_field(name, value)
    return if name.blank? || value.blank?
    @fields[name.to_s] = value.to_s
  end

  def add_fields(params = {})
    params.each do |field, v|
      add_field(field, v) unless field.blank?
    end
  end

  def encrypted_data
    raw_data = @fields.sort.map!{|k,v| "#{k}=#{v}"}.join('&')
    hash_raw_data = "HashKey=#{AllpayGoodsService.hash_key}&#{raw_data}&HashIV=#{AllpayGoodsService.hash_iv}"
    url_encode_data = AllpayGoodsService.url_encode(hash_raw_data)
    url_encode_data.downcase!

    add_field 'CheckMacValue', Digest::MD5.hexdigest(url_encode_data).upcase
  end

  # Allpay .NET url encoding
  # Code based from CGI.escape()
  # Some special characters (e.g. "()*!") are not escaped on Allpay server when they generate their check sum value, causing CheckMacValue Error.
  #
  # TODO: The following characters still cause CheckMacValue error:
  #       '<', "\n", "\r", '&'
  def self.url_encode(text)
    text = text.dup
    text.gsub!(/([^ a-zA-Z0-9\(\)\!\*_.-]+)/) do
      '%' + $1.unpack('H2' * $1.bytesize).join('%')
    end
    text.tr!(' ', '+')
    text
  end
end