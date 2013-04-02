class CreateEventImages < ActiveRecord::Migration
  def change
    create_table :event_images do |t|
      t.text :caption
      t.integer :event_id

      t.timestamps
    end
  end
end
