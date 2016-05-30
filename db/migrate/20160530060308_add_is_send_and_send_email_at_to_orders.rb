class AddIsSendAndSendEmailAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_send_survey_email, :boolean, default: false
    add_column :orders, :send_survey_email_at, :datetime
  end
end