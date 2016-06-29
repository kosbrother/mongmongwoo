class Admin::ConfirmInvoicesController < AdminController
  before_action :require_manager

  def index
    params[:status] ||= AdminCart::STATUS[:shipping]
    @invoices = AdminCart.includes(:taobao_supplier, admin_cart_items: [:item, :item_spec]).where(status: params[:status]).paginate(page: params[:page])
  end
end