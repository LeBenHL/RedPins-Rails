class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.integer :user_id
      t.string :event_id
      t.string :integer

      t.timestamps
    end
  end
end
