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

require 'spec_helper'

describe Event do

  before(:each) do
    @user = User.create(:email => 'email@email.com', :facebook_id => 'testUser', :firstname => 'Red', :lastname => 'Pin')
    @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
  end

  it 'adds an event into the database with URL' do
    response = Event.add('test event1', DateTime.new(2013,4,1), DateTime.new(2013,4,4),"Berkeley", @user.facebook_id, "google.com")
    expect(response).to eq(RedPins::Application::SUCCESS)
  end
  
  it 'adds an event into the database without URL' do
    response = Event.add('test event2', DateTime.new(2013,3,9), DateTime.new(2015,1,9), "Berkeley",  @user.facebook_id)
    expect(response).to eq(RedPins::Application::SUCCESS)
  end
  
  it 'adds an event with the same start date and end date' do
    response = Event.add('testevent3', DateTime.new(2013,1,2), DateTime.new(2013,1,2), "Berkeley", @user.facebook_id)
    response.should equal(RedPins::Application::SUCCESS)
  end
  
  it 'refuses to add an event without a location' do
    response = Event.add('testevent4', DateTime.new(2013,1,2), DateTime.new(2013,1,2), "", @user.facebook_id)
    response.should equal(RedPins::Application::ERR_BAD_LOCATION)
  end
  
  it 'refuses to add an event without a title' do
    response = Event.add('', DateTime.new(2013,1,9), DateTime.new(2013,1,9), "Berkeley", @user.facebook_id)
    response.should equal(RedPins::Application::ERR_BAD_TITLE)
  end
  
  it 'refuses to add an event without a start time' do
    response = Event.add('OTG', "", DateTime.new(2013,1,9), "Berkeley", @user.facebook_id)
    response.should equal(RedPins::Application::ERR_BAD_START_TIME)
  end
  
  it 'refuses to add an event without an end time' do
    response = Event.add('OTG', DateTime.new(2013,4,10), "", "Berkeley", @user.facebook_id)
    response.should equal(RedPins::Application::ERR_BAD_END_TIME)
  end

  it 'knows how many likes and dislikes it has' do
    @user1 = User.create(:email => 'email1@email.com', :facebook_id => 'testUser1', :firstname => 'Red', :lastname => 'Pin')
    @user2 = User.create(:email => 'email2@email.com', :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
    @user3 = User.create(:email => 'email3@email.com', :facebook_id => 'testUser3', :firstname => 'Red', :lastname => 'Pin')
    @user4 = User.create(:email => 'email4@email.com', :facebook_id => 'testUser4', :firstname => 'Red', :lastname => 'Pin')
    @user5 = User.create(:email => 'email5@email.com', :facebook_id => 'testUser5', :firstname => 'Red', :lastname => 'Pin')
    Like.create(:event_id => @event.id, :user_id => @user1.id, :like => true)
    Like.create(:event_id => @event.id, :user_id => @user2.id, :like => true)
    Like.create(:event_id => @event.id, :user_id => @user3.id, :like => false)
    Like.create(:event_id => @event.id, :user_id => @user4.id, :like => false)
    Like.create(:event_id => @event.id, :user_id => @user5.id, :like => true)
    ratings = @event.getRatings
    ratings[:likes].should equal(3)
    ratings[:dislikes].should equal(2)
  end

  it 'returns all comments associated with it' do
    @user1 = User.create(:email => 'email1@email.com', :facebook_id => 'testUser1', :firstname => 'Red', :lastname => 'Pin')
    @user2 = User.create(:email => 'email2@email.com', :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
    @user3 = User.create(:email => 'email3@email.com', :facebook_id => 'testUser3', :firstname => 'Red', :lastname => 'Pin')
    @user1.postComment(@event.id, 'I LOVE THIS EVENT')
    @user1.postComment(@event.id, 'I HATE THIS EVENT')
    @user2.postComment(@event.id, 'WOW SO BIPOLAR')
    @user2.postComment(@event.id, 'REDPIN USERS HIGH INTELLIGENCE')
    @user3.postComment(@event.id, 'WOW GUYS JUST LEAVE PLEASE BEFORE BAN')
    commentsArray = @event.getComments
    commentsArray.length.should equal(5)
  end

end
