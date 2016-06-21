class Admin::AdminCartsController < AdminController

  def checkout
    @admin_cart_items = current_admin_cart.admin_cart_items.recent.includes({item: :specs}, :item_spec)
    @taobao_list = TaobaoSupplier.all
    @first_taobao_items = @taobao_list[0].items
    @first_item_specs = @first_taobao_items[0].specs
  end

  def submit

  end
end
