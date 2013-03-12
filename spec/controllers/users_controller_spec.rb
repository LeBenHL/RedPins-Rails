require 'spec_helper'

describe UsersController do

  SUCCESS = 1
  ERR_NO_USER_EXISTS = -1
  ERR_USER_EXISTS = -2
  ERR_BAD_EMAIL = -3
  ERR_BAD_FACEBOOK_ID = -4
  ERR_USER_LIKE_EVENT = -8

  describe 'Post #add', :type => :request do
    it 'creates a user object' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
    end

    it 'refuses to create users with duplicate emails' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      params2 = { email: 'email@email.com', facebook_id: 'testUser2' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/add.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_USER_EXISTS
    end

    it 'refuses to create users with duplicate facebook ids' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      params2 = { email: 'newEmail@email.com', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/add.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_USER_EXISTS
    end

    it 'refuses to create users with invalid email' do
      params = { email: 'fakeemail', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_BAD_EMAIL
    end
  end

  describe 'Post #login', :type => :request do
    it 'login when given valid account and email' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/login.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
    end

    it 'refuse login to users with wrong facebook id' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      params2 = { email: 'email@email.com', facebook_id: 'testUser2' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/login.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_NO_USER_EXISTS
    end

  end

  describe 'Post #likeEvent', :type => :request do
    it 'should return SUCCESS when a user likes an event that actually exists' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      params = { event_id: @event.id, facebook_id: 'testUser', like: true }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
    end

    it 'should return ERR_USER_LIKE_EVENT when a user likes an event that does not exist' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      params = { event_id: 1, facebook_id: 'testUser', like: true }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_USER_LIKE_EVENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user likes an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      params = { event_id: @event.id, facebook_id: 'testUser2', like: true }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_NO_USER_EXISTS
    end

  end

  describe 'Post #removeLike', :type => :request do
    it 'should return SUCCESS when a user removes a like for an event succesfully' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      @like = Like.create(:event_id => @event.id, :user_id => @user.id, :like => true)
      params = { event_id: @event.id, facebook_id: 'testUser' }
      post '/users/removeLike.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
    end

    it 'should return ERR_USER_LIKE_EVENT when a user is unable to remove a like for an event' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      params = { event_id: @event.id, facebook_id: 'testUser' }
      post '/users/removeLike.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_USER_LIKE_EVENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user removes a like but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      params = { event_id: @event.id, facebook_id: 'testUser2'}
      post '/users/removeLike.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_NO_USER_EXISTS
    end

  end

  describe 'Post #likeEvent?', :type => :request do
    it 'alreadyLikedEvent return TRUE if user already liked/disliked an event' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      @like = Like.create(:event_id => @event.id, :user_id => @user.id, :like => true)
      params = { event_id: @event.id, facebook_id: 'testUser' }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
      parsed_body['alreadyLikedEvent'].should == true
    end

    it 'alreadyLikedEvent should return FALSE if user did not like/dislike the event' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      params = { event_id: @event.id, facebook_id: 'testUser' }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
      parsed_body['alreadyLikedEvent'].should == false
    end

    it 'should return ERR_NO_USER_EXISTS when we attempt to check if a user already liked an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      @user = User.create(:email => "email@email.com", :facebook_id => 'testUser')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      params = { event_id: @event.id, facebook_id: 'testUser2'}
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_NO_USER_EXISTS
    end

  end

end
