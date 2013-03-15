require 'spec_helper'

describe EventsController do

  describe 'Post #getRatings', :type => :request do
    before(:each) do
      @user = User.create(:email => 'email@email.com', :facebook_id => 'testUser', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
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

  describe 'Post #getComments', :type => :request do
    before(:each) do
      @user = User.create(:email => 'email@email.com', :facebook_id => 'testUser', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    end

    it 'should return all the comments associated to an event' do
      @user1 = User.create(:email => 'email1@email.com', :facebook_id => 'testUser1', :firstname => 'Red', :lastname => 'Pin')
      @user2 = User.create(:email => 'email2@email.com', :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
      @user3 = User.create(:email => 'email3@email.com', :facebook_id => 'testUser3', :firstname => 'Red', :lastname => 'Pin')
      @user1.postComment(@event.id, 'I LOVE THIS EVENT')
      @user1.postComment(@event.id, 'I HATE THIS EVENT')
      @user2.postComment(@event.id, 'WOW SO BIPOLAR')
      @user2.postComment(@event.id, 'REDPIN USERS HIGH INTELLIGENCE')
      @user3.postComment(@event.id, 'WOW GUYS JUST LEAVE PLEASE BEFORE BAN')
      params = { event_id: @event.id }
      post '/events/getComments.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['comments'].length.should equal(5)
    end


    it 'should return ERR_NO_EVENT_EXISTS if we ask for a list of comments of a event that does not exist in the database' do
      params = { event_id: 100 }
      post '/events/getComments.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_EVENT_EXISTS)
    end

  end

  describe 'Post #getEvent', :type => :request do
    before(:each) do
      @user1 = User.create(:email => 'email1@email.com', :facebook_id => 'testUser1', :firstname => 'Red', :lastname => 'Pin')
      @user2 = User.create(:email => 'email2@email.com', :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user1.id)
    end

    it 'should return SUCCESS if retrieve a valid event and set owner as true if owner of the event does the API call' do
      params = { event_id: @event.id, facebook_id: 'testUser1' }
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['event']['id'].should equal(@event.id)
      parsed_body['event']['owner'].should equal(true)
    end

    it 'should return SUCCESS if retrieve a valid event and set owner as false if non-owner of the event does the API call' do
      params = { event_id: @event.id, facebook_id: 'testUser2' }
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['event']['id'].should equal(@event.id)
      parsed_body['event']['owner'].should equal(false)
    end


    it 'should return ERR_NO_EVENT_EXISTS if we ask for an event that does not exist in the database' do
      params = { event_id: 100, facebook_id: 'testUser1' }
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_EVENT_EXISTS)
    end

    it 'should return ERR_NO_USER_EXISTS when a user asks an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser3'}
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_USER_EXISTS)
    end

  end

end
