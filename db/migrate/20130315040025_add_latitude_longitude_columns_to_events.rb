class AddLatitudeLongitudeColumnsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :latitude, :double
    add_column :events, :longitude, :double
  end
end
