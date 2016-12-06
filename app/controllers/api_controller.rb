class ApiController < ActionController::Base
  rescue_from Exception do |e|
    error(e)
  end

  def android_version
    render json: AndroidVersion.last
  end

  def get_new_app
    url = "http://shop.mmwooo.com/v2/official"
    coupon = "首下載即可享優惠"
    render status: 200, json: { is_ready: true, url: url , coupon: coupon}
  end

  private

  def find_county
    @county = County.find(params[:county_id])
  end

  def find_town
    @town = @county.towns.find(params[:town_id]) 
  end

  def find_road
    @road = @town.roads.find(params[:road_id])
  end

  def error(e)
    if env["ORIGINAL_FULLPATH"] =~ /^\/api/
      error_info = {
        :exception => "#{e.class.name} : #{e.message}",
      }
      error_info[:trace] = e.backtrace[0,10] if Rails.env.development?
      Rails.logger.error("error: #{error_info}")
      render status: 500, json: {error: {message: error_info.to_s}}
    else
      raise e
    end
  end
end