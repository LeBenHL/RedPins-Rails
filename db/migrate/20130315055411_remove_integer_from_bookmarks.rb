class RemoveIntegerFromBookmarks < ActiveRecord::Migration
  def change
    remove_column :bookmarks, :integer
  end
end
