class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :url
      t.string :location
      t.datetime :time

      t.timestamps
    end
  end
end
