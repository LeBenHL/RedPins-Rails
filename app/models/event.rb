# == Schema Information
#
# Table name: event
#
#  id          :integer          not null, primary key
#  location    :string(255)      not null
#  start_time  :datetime         not null
#  title       :string(255)      not null
#  url         :string(255)      not null
#  user_id     :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Event < ActiveRecord::Base
  attr_accessible :location, :time, :title, :url, :user_id
  validates :title, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :location, :presence => true
  has_many :users, :through => :likes
  
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
  
end
