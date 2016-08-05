class NotificationEncode < ActiveRecord::Migration
  def change
    execute("ALTER TABLE notifications MODIFY content_title TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;")
    execute("ALTER TABLE notifications MODIFY content_text TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;")
  end
end
