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
#  end_time   :datetime
#  user_id    :integer
#  canceled   :boolean          default(FALSE), not null
#  latitude   :float
#  longitude  :float
#

class Event < ActiveRecord::Base
  attr_accessible :location, :latitude, :longitude, :title, :url, :user_id, :start_time, :end_time, :canceled
  validates :title, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :location, :presence => true
  validates :user_id, :presence => true
  belongs_to :creator, :class_name => 'User', :foreign_key => "user_id"
  validates :creator, :presence => true
  has_many :likes
  has_many :users, :through => :likes
  has_many :comments
  has_many :users, :through => :comments
  has_many :bookmarks
  has_many :events, :through => :bookmarks
  
  def self.add(title, start_time, end_time, location, facebook_id, url = "", latitude = 360, longitude = 360)
    begin
      @creator = User.find_by_facebook_id(facebook_id)
      @event = Event.create!(:title => title, :start_time => start_time, :end_time => end_time, :location => location, :user_id => @creator['id'], :url => url, :latitude => latitude, :longitude => longitude)
    rescue => exception
      message = exception.message
      case
        when message =~ /Title can't be blank/i
          return RedPins::Application::ERR_BAD_TITLE
        when message =~ /Location can't be blank/i
          return RedPins::Application::ERR_BAD_LOCATION
        when message =~ /Start time can't be blank/i
          return RedPins::Application::ERR_BAD_START_TIME
        when message =~ /End time can't be blank/i
          return RedPins::Application::ERR_BAD_END_TIME
        else
          return RedPins::Application::ERR_EVENT_CREATION
      end
    end
    return RedPins::Application::SUCCESS
  end

  def getRatings
    likes = self.likes.where(:like => true).count
    dislikes = self.likes.where(:like => false).count
    return { :likes => likes, :dislikes => dislikes}
  end

  def getComments
    commentsArray = []
    self.comments.each do |comment|
      hash = {}
      hash[:facebook_id] = comment.user.facebook_id
      hash[:created_at] = comment.created_at
      hash[:firstname] = comment.user.firstname
      hash[:lastname] = comment.user.lastname
      hash[:comment] = comment.comment
      commentsArray.push(hash)
    end
    return commentsArray
  end
  
  def searchByEvent(text)
    eventsArray = []
    self.title.each do |eventName|
      hash = {}
      hash[:title] = eventName.title
      hash[:facebook_id] = eventName.user.facebook_id
      hash[:created_at] = eventName.created_at
      hash[:firstname] = eventName.user.firstname
      hash[:lastname] = eventName.user.lastname
      hash[:comment] = eventName.comment
      if eventName == text
        eventsArray.push(hash)
      end
    end
    return eventsArray
  end
  
end
