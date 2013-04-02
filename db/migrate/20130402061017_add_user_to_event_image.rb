class AddUserToEventImage < ActiveRecord::Migration
  def change
    add_column :event_images, :user_id, :integer
  end
end
