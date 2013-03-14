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

require 'spec_helper'

describe Event do
  before(:each) do
    @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com')
  end

  it 'adds an event into the database with URL' do
    response = Event.add('test event1', DateTime.new(2013,4,1), "berkeley", "google.com")
    expect(response).to eq(RedPins::Application::SUCCESS)
  end
  
  it 'adds an event into the database without URL' do
    response = Event.add('test event2', DateTime.new(2013,3,9), "san jose, ca")
    expect(response).to eq(RedPins::Application::SUCCESS)
  end

  it 'knows how many likes and dislikes it has' do
    @user1 = User.create(:email => 'email1@email.com', :facebook_id => 'testUser1')
    @user2 = User.create(:email => 'email2@email.com', :facebook_id => 'testUser2')
    @user3 = User.create(:email => 'email3@email.com', :facebook_id => 'testUser3')
    @user4 = User.create(:email => 'email4@email.com', :facebook_id => 'testUser4')
    @user5 = User.create(:email => 'email5@email.com', :facebook_id => 'testUser5')
    Like.create(:event_id => @event.id, :user_id => @user1.id, :like => true)
    Like.create(:event_id => @event.id, :user_id => @user2.id, :like => true)
    Like.create(:event_id => @event.id, :user_id => @user3.id, :like => false)
    Like.create(:event_id => @event.id, :user_id => @user4.id, :like => false)
    Like.create(:event_id => @event.id, :user_id => @user5.id, :like => true)
    ratings = @event.getRatings
    ratings[:likes].should equal(3)
    ratings[:dislikes].should equal(2)
  end

end
