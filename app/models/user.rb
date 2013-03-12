# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  email       :string(255)      not null
#  facebook_id :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'valid_email'
class User < ActiveRecord::Base
  attr_accessible :email, :facebook_id, :id
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :facebook_id, :presence => true, :uniqueness => true
  has_many :events, :through => :likes

  def self.login(facebook_id)
    @user = User.where(:facebook_id => facebook_id)[0]
    if @user
      return RedPins::Application::SUCCESS
    else
      return RedPins::Application::ERR_NO_USER_EXISTS
    end
  end

  def self.add(email, facebook_id)
    begin
      @user = User.create!(:email => email, :facebook_id => facebook_id)
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
      end
    end
    return RedPins::Application::SUCCESS
  end

  def self.getUser(facebook_id)
    return User.where(:facebook_id => facebook_id)[0]
  end

  def rateEvent(event_id, like)
    begin
      @like = Like.create!(:user_id => self.id, :event_id => event_id, :like => like)
    rescue => ex
      return false
    end
    return true
  end

  def rateEvent?(event_id)
    @like = Like.where(:user_id => self.id, :event_id => event_id)[0]
    return true unless @like.nil?
    return false
  end

  def getRatingForEvent(event_id)
    Like.where(:user_id => self.id, :event_id => event_id)[0]
  end

  #TEST
  def deleteRatingForEvent(event_id)
    @like = Like.where(:user_id => self.id, :event_id => event_id)[0]
    return false if @like.nil?
    @like.delete
    return true
  end
end
