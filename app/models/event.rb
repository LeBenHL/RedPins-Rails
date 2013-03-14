# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  url        :string(255)
#  location   :string(255)
#  start_time :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :string(255)
#  end_time   :datetime
#

class Event < ActiveRecord::Base
  attr_accessible :location, :time, :title, :url, :user_id, :start_time, :end_time
  validates :title, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :location, :presence => true
  has_many :likes
  has_many :users, :through => :likes
  has_many :comments
  has_many :users, :through => :comments
  
  def self.add(title, start_time, end_time, location, url = "")
    begin
      @event = Event.create!(:title => title, :start_time => start_time, :end_time => end_time, :location => location, :url => url)
    rescue => exception
      message = exception.message
      case
        when message =~ /Title can't be blank/i
          return RedPins::Application::ERR_BAD_TITLE
        when message =~ /Location can't be blank/i
          return RedPins::Application::ERR_BAD_LOCATION
        when message =~ /Time can't be blank/i
          return RedPins::Application::ERR_BAD_TIME
      end
    end
    return RedPins::Application::SUCCESS
  end

  def getRatings
    likes = self.likes.where(:like => true).count
    dislikes = self.likes.where(:like => false).count
    return { :likes => likes, :dislikes => dislikes}
  end
  
end