# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  email       :string(255)      not null
#  facebook_id :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  firstname   :string(255)
#  lastname    :string(255)
#

require 'valid_email'
require 'net/https'
require 'json'

class User < ActiveRecord::Base
  attr_accessible :email, :facebook_id, :id, :firstname, :lastname
  validates :email, :presence => true, :email => true
  validates :facebook_id, :presence => true, :uniqueness => true
  validates :firstname, :presence => true
  validates :lastname, :presence => true
  has_many :created_events, :class_name => 'Event'
  has_many :likes, :dependent => :destroy
  has_many :events, :through => :likes
  has_many :comments, :dependent => :destroy
  has_many :events, :through => :comments
  has_many :bookmarks, :dependent => :destroy
  has_many :events, :through => :bookmarks
  has_many :event_images
  has_many :recent_events, :dependent => :destroy
  has_many :events, :through => :recent_events

  def self.login(facebook_id, session_token)
    begin
      @user = User.where(:facebook_id => facebook_id)[0]
      if @user
        return self.verify(facebook_id, session_token)
      else
        return RedPins::Application::ERR_NO_USER_EXISTS
      end
    rescue => ex
      return RedPins::Application::ERR_NO_USER_EXISTS
    end
  end

  def self.add(email, facebook_id, firstname, lastname)
    begin
      @user = User.create!(:email => email, :facebook_id => facebook_id, :firstname => firstname, :lastname => lastname)
    rescue => ex
      message = ex.message
      case
        when message =~ /Email can't be blank/i
          return RedPins::Application::ERR_BAD_EMAIL
        when message =~ /Email is invalid/i
          return RedPins::Application::ERR_BAD_EMAIL
        when message =~ /Facebook has already been taken/i
          return RedPins::Application::ERR_USER_EXISTS
        when message =~ /Facebook can't be blank/i
          return RedPins::Application::ERR_BAD_FACEBOOK_ID
        else
          return RedPins::Application::ERR_USER_CREATION
      end
    end
    return RedPins::Application::SUCCESS
  end

  def self.getUser(facebook_id)
    return User.where(:facebook_id => facebook_id)[0]
  end

  def self.verify(facebook_id, session_token)
    url = 'https://graph.facebook.com/oauth/access_token?client_id=' + RedPins::Application::APP_ID + '&client_secret=' + RedPins::Application::APP_SECRET + '&grant_type=client_credentials'
    fb_access_token_url = URI.parse(URI.encode(url))
    https = Net::HTTP.new(fb_access_token_url.host, fb_access_token_url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = https.request_get(fb_access_token_url.path + '?' +
                                            fb_access_token_url.query)
    access_token = resp.body.split('=')[1]
    url = 'https://graph.facebook.com/debug_token?input_token=' + session_token + '&access_token=' + access_token
    debug_token_url = URI.parse(URI.encode(url))
    https = Net::HTTP.new(debug_token_url.host, debug_token_url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = https.request_get(debug_token_url.path + '?' +
                                 debug_token_url.query)
    json = JSON.parse(resp.body)
    if json['data']['user_id'].to_s == facebook_id
      return RedPins::Application::SUCCESS
    else
      return RedPins::Application::ERR_USER_VERIFICATION
    end
  end

  def likeEvent(event_id, like)
    begin
      @like = Like.create!(:user_id => self.id, :event_id => event_id, :like => like)
    rescue => ex
      return RedPins::Application::ERR_USER_LIKE_EVENT
    end
    return RedPins::Application::SUCCESS
  end

  def likeEvent?(event_id)
    @like = Like.where(:user_id => self.id, :event_id => event_id)[0]
    return {:alreadyLikedEvent => true, :like => @like.like} unless @like.nil?
    return {:alreadyLikedEvent => false}
  end

  def getRatingForEvent(event_id)
    Like.where(:user_id => self.id, :event_id => event_id)[0]
  end

  def removeLike(event_id)
    @like = Like.where(:user_id => self.id, :event_id => event_id)[0]
    return RedPins::Application::ERR_USER_LIKE_EVENT if @like.nil?
    @like.delete
    return RedPins::Application::SUCCESS
  end

  def postComment(event_id, comment)
    begin
      @comment = Comment.create!(:user_id => self.id, :event_id => event_id, :comment => comment)
    rescue => ex
      return RedPins::Application::ERR_USER_POST_COMMENT
    end
    return RedPins::Application::SUCCESS
  end

  def bookmarkEvent(event_id)
    begin
      @bookmark = Bookmark.create!(:user_id => self.id, :event_id => event_id)
    rescue => ex
      return RedPins::Application::ERR_USER_BOOKMARK
    end
    return RedPins::Application::SUCCESS
  end

  def removeBookmark(event_id)
    begin
      @bookmark = Bookmark.where(:user_id => self.id, :event_id => event_id)[0]
      @bookmark.delete
    rescue => ex
      return RedPins::Application::ERR_USER_REMOVE_BOOKMARK
    end
    return RedPins::Application::SUCCESS
  end

  def deleteEvent(event_id)
    begin
      @event = Event.find(event_id)
      return RedPins::Application::ERR_USER_DELETE_EVENT unless @event.user_id == self.id
      @event.delete
    rescue => ex
      return RedPins::Application::ERR_USER_DELETE_EVENT
    end
    return RedPins::Application::SUCCESS
  end

  def cancelEvent(event_id)
    begin
      @event = Event.find(event_id)
      return RedPins::Application::ERR_USER_CANCEL_EVENT unless @event.user_id == self.id
      @event.update_attribute(:canceled, true)
    rescue => ex
      return RedPins::Application::ERR_USER_CANCEL_EVENT
    end
    return RedPins::Application::SUCCESS
  end

  def restoreEvent(event_id)
    begin
      @event = Event.find(event_id)
      return RedPins::Application::ERR_USER_RESTORE_EVENT unless @event.user_id == self.id
      @event.update_attribute(:canceled, false)
    rescue => ex
      return RedPins::Application::ERR_USER_RESTORE_EVENT
    end
    return RedPins::Application::SUCCESS
  end

  def uploadPhoto(event_id, photo, caption = "")
    begin
      @event_image = EventImage.create!(:event_id => event_id, :user_id => self.id, :caption => caption, :photo => photo)
    rescue => ex
      return {:errCode => RedPins::Application::ERR_USER_UPLOAD_PHOTO, :message => ex.message}
    end
    return {:errCode => RedPins::Application::SUCCESS}
  end

  def getBookmarks(page = 1, per_page = 6)
    begin
      limit = per_page
      offset = (page - 1) * per_page
      bookmarks = Bookmark.where(:user_id => self.id).order("created_at DESC").limit(limit).offset(offset)
      events = []
      bookmarks.each do |bookmark|
        event = bookmark.event
        event_attributes = event.attributes
        if event.user_id == self.id
          event_attributes[:owner] = true
        else
          event_attributes[:owner] = false
        end
        if event.event_images.count > 0
          event_attributes[:isPhoto] = true
          event_attributes[:photo] = event.event_images.order("created_at DESC")[0].photo.url(:thumbnail)
        else
          event_attributes[:isPhoto] = false
        end
        events.push(event_attributes)
      end
      if self.bookmarks.length > offset + limit
        next_page = page + 1
      else
        next_page = nil
      end
      return {:errCode => RedPins::Application::SUCCESS, :events => events, :next_page => next_page}
    rescue => ex
      return {:errCode => RedPins::Application::ERR_USER_GET_BOOKMARKS}
    end
  end
  
  def getMyEvents(page = 1, per_page = 6)
    begin
      limit = per_page
      offset = (page - 1) * per_page
      myEvents = Event.where(:user_id => self.id).order("created_at DESC").limit(limit).offset(offset)
      events = []
      myEvents.each do |myEvent|
        event_attributes = myEvent.attributes
        if myEvent.user_id == self.id
          event_attributes[:owner] = true
        else
          event_attributes[:owner] = false
        end
        events.push(event_attributes)
      end
      if self.created_events.length > offset + limit
        next_page = page + 1
      else
        next_page = nil
      end
      return {:errCode => RedPins::Application::SUCCESS, :myEvents => events, :next_myEvent_page => next_page}
    rescue => ex
      return {:errCode => RedPins::Application::ERR_USER_GET_MY_EVENTS}
    end
  end

  def removeComment(comment_id)
    begin
      comment = Comment.find(comment_id)
      if comment.user_id == self.id
        comment.destroy
        return RedPins::Application::SUCCESS
      else
        return RedPins::Application::ERR_USER_REMOVE_COMMENT
      end
    rescue => ex
      return RedPins::Application::ERR_USER_REMOVE_COMMENT
    end
  end

  def logEvent(event_id)
    begin
      @log = RecentEvent.where(:user_id => self.id, :event_id => event_id)[0]
      @log.touch
      return @log
    rescue
      @log = RecentEvent.create(:user_id => self.id, :event_id => event_id)
      return @log
    end
  end

  def getRecentEvents(page = 1, per_page = 10)
    begin
      limit = per_page
      offset = (page - 1) * per_page
      logs = RecentEvent.where(:user_id => self.id).order("updated_at DESC").limit(limit).offset(offset)
      events = []
      logs.each do |log|
        event = log.event
        event_attributes = event.attributes
        if event.user_id == self.id
          event_attributes[:owner] = true
        else
          event_attributes[:owner] = false
        end
        if event.event_images.count > 0
          event_attributes[:isPhoto] = true
          event_attributes[:photo] = event.event_images.order("created_at DESC")[0].photo.url(:thumbnail)
        else
          event_attributes[:isPhoto] = false
        end
        events.push(event_attributes)
      end
      if self.recent_events.length > offset + limit
        next_page = page + 1
      else
        next_page = nil
      end
      return {:errCode => RedPins::Application::SUCCESS, :events => events, :next_page => next_page}
    rescue => ex
      return {:errCode => RedPins::Application::ERR_USER_GET_RECENT_EVENTS}
    end
  end

end
