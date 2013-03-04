require 'valid_email'
class User < ActiveRecord::Base
  attr_accessible :email, :facebook_id
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :facebook_id, :presence => true, :uniqueness => true

  def self.login(email, facebook_id)
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
    return SUCCESS
  end
end
