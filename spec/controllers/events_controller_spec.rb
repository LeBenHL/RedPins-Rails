require 'spec_helper'

describe EventsController do

  describe 'Post #getRatings?', :type => :request do
    before(:each) do
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com')
    end

    it 'should return the correct amount of likes an dislikes it has' do
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
      params = { event_id: @event.id }
      post '/events/getRatings.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['likes'].should equal(3)
      parsed_body['dislikes'].should equal(2)
    end


    it 'should return ERR_NO_EVENT_EXISTS if we ask for a rating for an event_id that does not exist in the database' do
      params = { event_id: 100 }
      post '/events/getRatings.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_EVENT_EXISTS)
    end

  end

end
