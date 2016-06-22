class Admin::AdminCartsController < AdminController

  def checkout
    @taobao_list = TaobaoSupplier.all
    @first_taobao_items = @taobao_list[0].items
    @first_item_specs = @first_taobao_items[0].specs
  end

  def submit

  end
end
