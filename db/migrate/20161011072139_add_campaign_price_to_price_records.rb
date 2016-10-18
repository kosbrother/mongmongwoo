class AddCampaignPriceToPriceRecords < ActiveRecord::Migration
  def change
    add_column :price_records, :campaign_price, :integer
  end
end
