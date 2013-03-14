class Bookmark < ActiveRecord::Base
  attr_accessible :event_id, :integer, :user_id
  belongs_to :user
  belongs_to :event
  validates :user, :presence => true
  validates :event, :presence => true
  validates :event_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :event_id}

end
