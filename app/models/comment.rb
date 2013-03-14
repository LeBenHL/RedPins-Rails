# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  event_id   :integer          not null
#  comment    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Comment < ActiveRecord::Base
  attr_accessible :comment, :event_id, :user_id, :created_at
  belongs_to :user
  belongs_to :event
  validates :user, :presence => true
  validates :event, :presence => true
  validates :event_id, :presence => true
  validates :user_id, :presence => true

end
