class Admin::ConfirmInvoicesController < AdminController
  before_action :require_manager

  def index
    params[:status] ||= AdminCart::STATUS[:shipping]
    @invoices = AdminCart.current_status(params[:status]).recent.paginate(page: params[:page])
  end

  def confirm
    shipping_invoice = AdminCart.current_status(AdminCart::STATUS[:shipping]).find(params[:id])
    invoice_items = shipping_invoice.admin_cart_items

    invoice_items.each do |cart_item|
      stock = Stock.find_by(item_id: cart_item.item_id)
      stock_spec = StockSpec.find_by(item_spec_id: cart_item.item_spec_id)

      if stock && stock_spec
        stock_spec.amount += cart_item.item_quantity
        stock_spec.save
      elsif stock && stock_spec.nil?
        new_stock_spec = stock.stock_specs.new
        new_stock_spec.item_spec = cart_item.item_spec
        new_stock_spec.amount = cart_item.item_quantity
        new_stock_spec.save
      else
        new_stock = Stock.new
        new_stock.item = cart_item.item
        new_stock.save

        new_stock_spec = new_stock.stock_specs.new
        new_stock_spec.item_spec = cart_item.item_spec
        new_stock_spec.amount = cart_item.item_quantity
        new_stock_spec.save
      end
    end

    shipping_invoice.update_attribute(:status, AdminCart::STATUS[:stock])

    redirect_to admin_confirm_invoices_path(status: AdminCart::STATUS[:stock])
  end
end