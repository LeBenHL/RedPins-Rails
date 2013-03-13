# == Schema Information
#
# Table name: event
#
#  id          :integer          not null, primary key
#  location    :string(255)      not null
#  time        :datetime         not null
#  title       :string(255)      not null
#  url         :string(255)      not null
#  user_id     :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Event < ActiveRecord::Base
  attr_accessible :location, :time, :title, :url, :user_id
  validates :title, :presence => true
  validates :time, :presence => true
  validates :location, :presence => true
  has_many :likes
  has_many :users, :through => :likes
  
  def self.add(title, time, location, url = "")
    begin
      @event = Event.create!(:title => title, :time => time, :location => location, :url => url)
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
