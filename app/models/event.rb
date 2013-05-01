# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :text
#  url         :string(255)
#  location    :string(255)
#  start_time  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  end_time    :datetime
#  user_id     :integer
#  canceled    :boolean          default(FALSE), not null
#  latitude    :float
#  longitude   :float
#  description :text
#

class Event < ActiveRecord::Base
  attr_accessible :location, :latitude, :longitude, :title, :url, :user_id, :start_time, :end_time, :canceled, :description, :id
  geocoded_by :location
  reverse_geocoded_by :latitude, :longitude, :address => :location
  before_validation :check_before_geocode
  searchable do
    text :title
    text :description
    text :comments do
      comments.map { |comment| comment.comment}
    end
    time :start_time, :end_time, :created_at, :updated_at
    integer :user_id
    float :rating
    boolean :canceled
    latlon(:coords) { Sunspot::Util::Coordinates.new(latitude, longitude) }
  end
  validates :title, :presence => true
  validates :location, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :user_id, :presence => true
  belongs_to :creator, :class_name => 'User', :foreign_key => "user_id"
  validates :creator, :presence => true
  validate :end_time_after_start_time
  has_many :likes, :dependent => :destroy
  has_many :users, :through => :likes
  has_many :comments, :dependent => :destroy
  has_many :users, :through => :comments
  has_many :bookmarks, :dependent => :destroy
  has_many :events, :through => :bookmarks
  has_many :event_images, :dependent => :destroy
  has_many :recent_events, :dependent => :destroy
  has_many :users, :through => :recent_events

  def end_time_after_start_time
    if !self.end_time.blank? and !self.start_time.blank? and self.end_time < self.start_time
      errors.add(:end_time, "Can't have event end at time before it starts'")
    end
  end

  def check_before_geocode
   if self.location
      geocode if self.latitude.nil? and self.longitude.nil?
    else
      reverse_geocode if self.location.nil?
   end
  end

  def rating
    likes = self.likes.where(:like => true).count
    likes.to_f / self.likes.count
  end
  
  def self.add(title, start_time, end_time, location, facebook_id, url = "", latitude = 37.8717, longitude = -122.2728, description = "")
    begin
      @creator = User.find_by_facebook_id(facebook_id)
      @event = Event.create!(:title => title, :start_time => start_time, :end_time => end_time, :location => location, :user_id => @creator['id'], :url => url, :latitude => latitude, :longitude => longitude, :description => description)
    rescue => exception
      message = exception.message
      case
        when message =~ /Title can't be blank/i
          return {:errCode => RedPins::Application::ERR_BAD_TITLE}
        when message =~ /Location can't be blank/i
          return {:errCode => RedPins::Application::ERR_BAD_LOCATION}
        when message =~ /Start time can't be blank/i
          return {:errCode => RedPins::Application::ERR_BAD_START_TIME}
        when message =~ /End time can't be blank/i
          return {:errCode => RedPins::Application::ERR_BAD_END_TIME}
        else
          return {:errCode => RedPins::Application::ERR_EVENT_CREATION}
      end
    end
    return {:errCode => RedPins::Application::SUCCESS, :event_id => @event.id}
  end

  def self.searchEvents(search_query, coords, user_id, page = 1, per_page = 10)
    events = Event.search do
      if (search_query.downcase == "everything")
        order_by(:rating, :desc)
      else
        fulltext search_query do
          boost_fields :title  => 3.0
          boost_fields :description => 2.0
        end
      end
      with(:canceled, false)
      with(:coords).in_radius(coords[0], coords[1], 10, :bbox => true)
      paginate :page => page, :per_page => per_page
    end
    event_list = []
    events.results.each do |event|
      attributes = event.attributes
      if event.user_id == user_id
        attributes[:owner] = true
      else
        attributes[:owner] = false
      end
      if event.event_images.count > 0
        attributes[:isPhoto] = true
        attributes[:photo] = event.event_images.order("created_at DESC")[0].photo.url(:thumbnail)
      else
        attributes[:isPhoto] = false
      end
      event_list.push(attributes)
    end
    return {:events => event_list, :next_page => events.results.next_page}
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
      hash[:comment_id] = comment.id
      hash[:facebook_id] = comment.user.facebook_id
      hash[:created_at] = comment.created_at
      hash[:firstname] = comment.user.firstname
      hash[:lastname] = comment.user.lastname
      hash[:comment] = comment.comment
      commentsArray.push(hash)
    end
    return commentsArray
  end

  def getPhotos
    @images = EventImage.where(:event_id => self.id).order('created_at DESC')
    urlArray = []
    @images.each do |image|
      urlArray.push(image.photo)
    end
    return {:errCode => RedPins::Application::SUCCESS, :urls => urlArray}
  end

=begin
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
=end
  
end
