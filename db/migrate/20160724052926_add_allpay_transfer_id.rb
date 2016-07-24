class AddAllpayTransferId < ActiveRecord::Migration
  def change
    add_column :orders, :allpay_transfer_id, :integer
  end
end
