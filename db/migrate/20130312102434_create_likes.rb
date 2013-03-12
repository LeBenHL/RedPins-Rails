class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :user_id, :null => false
      t.integer :event_id, :null => false
      t.boolean :like, :null => false

      t.timestamps
    end
  end
end
