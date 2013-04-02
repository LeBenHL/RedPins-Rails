class AddAttachmentPhotoToEventImages < ActiveRecord::Migration
  def self.up
    change_table :event_images do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :event_images, :photo
  end
end
