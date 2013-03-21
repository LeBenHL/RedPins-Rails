# == Schema Information
#
# Table name: bookmarks
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :integer
#

class Bookmark < ActiveRecord::Base
  attr_accessible :event_id, :integer, :user_id
  belongs_to :user
  belongs_to :event
  validates :user, :presence => true
  validates :event, :presence => true
  validates :event_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :event_id}

end
