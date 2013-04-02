# == Schema Information
#
# Table name: event_images
#
#  id                 :integer          not null, primary key
#  caption            :text
#  event_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  user_id            :integer
#

class EventImage < ActiveRecord::Base
  attr_accessible :caption, :event_id, :user_id
  belongs_to :event
  belongs_to :user
  has_attached_file :photo, :styles => { :thumbnail => "250x250>" }
  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 5.megabytes

end
