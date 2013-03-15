class ChangeEventIdToIntegerInBookmarks < ActiveRecord::Migration
  def change
    remove_column :bookmarks, :event_id
    add_column :bookmarks, :event_id, :integer
  end
end
