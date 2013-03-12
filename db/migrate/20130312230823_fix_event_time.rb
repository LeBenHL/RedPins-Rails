class FixEventTime < ActiveRecord::Migration
  def change
    add_column :events, :end_time, :datetime
    rename_column :events, :time, :start_time
  end
end
