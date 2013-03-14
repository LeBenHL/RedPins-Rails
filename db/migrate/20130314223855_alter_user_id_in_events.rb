class AlterUserIdInEvents < ActiveRecord::Migration
  def change
    remove_column :events, :user_id
    add_column :events, :user_id, :integer
  end
end
