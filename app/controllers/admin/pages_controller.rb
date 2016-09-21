class Admin::PagesController < AdminController
  def home
    if current_admin && current_admin.manager?
      redirect_to status_index_admin_orders_path
    elsif current_admin && current_admin.staff?
      redirect_to admin_items_path
    else
      flash[:alert] = "請先登入後台"
      redirect_to admin_signin_path
    end
  end
end