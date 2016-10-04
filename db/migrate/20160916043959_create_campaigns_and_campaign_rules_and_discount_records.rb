class CreateCampaignsAndCampaignRulesAndDiscountRecords < ActiveRecord::Migration
  def change
    create_table :campaign_rules do |t|
      t.string :title
      t.string :description
      t.integer :discount_type
      t.float :discount_percentage
      t.integer :discount_money
      t.integer :rule_type
      t.integer :threshold
      t.string :banner_cover
      t.string :card_icon
      t.string :list_icon
      t.datetime :created_at
      t.datetime :valid_until
      t.datetime :deleted_at
      t.boolean :is_valid, default: true
    end

    create_table :campaigns do |t|
      t.integer :campaign_rule_id, index: true
      t.references :discountable, polymorphic: true, index: true
    end


    create_table :discount_records do |t|
      t.integer :campaign_rule_id, index: true
      t.references :discountable, polymorphic: true, index: true
      t.datetime :created_at
    end
  end
end
