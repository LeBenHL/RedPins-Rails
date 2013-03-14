# == Schema Information
#
# Table name: bookmarks
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  event_id   :string(255)
#  integer    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
