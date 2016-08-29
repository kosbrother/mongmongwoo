class MessagesEncode < ActiveRecord::Migration
  def change
    execute("ALTER TABLE messages MODIFY title TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;")
    execute("ALTER TABLE messages MODIFY content TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;")
  end
end
