# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  event_id   :integer          not null
#  like       :boolean          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Like < ActiveRecord::Base
  attr_accessible :event_id, :like, :user_id
  belongs_to :user
  belongs_to :event
  validates :user, :presence => true
  validates :event, :presence => true
  validates :event_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :event_id}

end
