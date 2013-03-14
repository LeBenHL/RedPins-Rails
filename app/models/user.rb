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
class User < ActiveRecord::Base
  attr_accessible :email, :facebook_id, :id, :firstname, :lastname
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :facebook_id, :presence => true, :uniqueness => true
  validates :firstname, :presence => true
  validates :lastname, :presence => true
  has_many :likes
  has_many :events, :through => :likes
  has_many :comments
  has_many :events, :through => :comments
  has_many :bookmarks
  has_many :events, :through => :bookmarks

  def self.login(facebook_id)
    @user = User.where(:facebook_id => facebook_id)[0]
    if @user
      return RedPins::Application::SUCCESS
    else
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
        when message =~ /Email has already been taken/i
          return RedPins::Application::ERR_USER_EXISTS
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

  def likeEvent(event_id, like)
    begin
      @like = Like.create!(:user_id => self.id, :event_id => event_id, :like => like)
    rescue => ex
      return false
    end
    return true
  end

  def likeEvent?(event_id)
    @like = Like.where(:user_id => self.id, :event_id => event_id)[0]
    return true unless @like.nil?
    return false
  end

  def getRatingForEvent(event_id)
    Like.where(:user_id => self.id, :event_id => event_id)[0]
  end

  def removeLike(event_id)
    @like = Like.where(:user_id => self.id, :event_id => event_id)[0]
    return false if @like.nil?
    @like.delete
    return true
  end

  def postComment(event_id, comment)
    begin
      @comment = Comment.create!(:user_id => self.id, :event_id => event_id, :comment => comment)
    rescue => ex
      return false
    end
    return true
  end

  def bookmarkEvent(event_id)
    begin
      @bookmark = Bookmark.create!(:user_id => self.id, :event_id => event_id)
    rescue => ex
      return false
    end
    return true
  end
end
