class AllpayController < ActionController::Base
  def create
    if PostToAllpayWorker.new.perform(params[:order_id], create_reply_allpay_index_url, status_update_allpay_index_url)
      @message = "已將編號：#{params[:order_id]} 成功傳送到歐付寶"
    else
      @message = "編號：#{params[:order_id]} 傳送到歐付寶 失敗"
    end
  end

  def status_update
  end

  def create_reply
  end
end