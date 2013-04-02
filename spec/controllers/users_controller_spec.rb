require 'spec_helper'

describe UsersController do

  before(:each) do
    @session_token = 'AAAEw2AGE0JYBAMc6qqcvAIDr28wPOCskrV3O2ZAB0GpTe2ddPFddIfUKN8JtkrY50afZCimIXv6w1YNhKl4SlEnrmDB10di7a3ZB9jMLagPRaIiPwhP'
    @session_token2 = 'BAAEw2AGE0JYBAESZAmjhyg27dAxFAd9ZCU385zVMUdZAF3mgkZCCVOb23hZCXQvvYtukcv1REFDTcTJJjP9OjlsqLsgDFoznMu4UZCEpxZBOH1IOoelZAPwU'
  end

  describe 'Post #add', :type => :request do

    it 'creates a user object' do
      params = { email: 'email@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token}
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'refuses to create users with duplicate facebook ids' do
      params = { email: 'email@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token }
      params2 = { email: 'newEmail@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/add.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_EXISTS
    end

    it 'refuses to create users with invalid email' do
      params = { email: 'fakeemail', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_BAD_EMAIL
    end

    it 'returns ERR_USER_VERIFICATION if we try adding a facebook_id user and the session_token does not belong to him/her' do
      params = { email: 'email@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => 'FAKETOKEN'}
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end
  end

  describe 'Post #login', :type => :request do
    it 'login when given valid account and email' do
      params = { email: 'email@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/login.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'refuse login to users with wrong facebook id' do
      params = { email: 'email@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token }
      params2 = { email: 'email@email.com', facebook_id: '1000004502306112', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/login.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'returns ERR_USER_VERIFICATION if we try logging in a facebook_id user and the session_token does not belong to him/her' do
      params = { email: 'email@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => @session_token }
      params2 = { email: 'email@email.com', facebook_id: '100000450230611', :firstname => 'Red', :lastname => 'Pin', :session_token => 'FAKETOKEN' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/login.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end
  end

  describe 'Post #likeEvent', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    end

    it 'should return SUCCESS when a user likes an event that actually exists' do
      params = { event_id: @event.id, facebook_id: '100000450230611', like: true, :session_token => @session_token }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_LIKE_EVENT when a user likes an event that does not exist' do
      params = { event_id: 100, facebook_id: '100000450230611', like: true, :session_token => @session_token }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_LIKE_EVENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user likes an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser2', like: true, :session_token => @session_token }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_LIKE_EVENT when a user attempts to like/dislike an event multiple times' do
      params = { event_id: @event.id, facebook_id: '100000450230611', like: true, :session_token => @session_token }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_LIKE_EVENT
    end

    it 'should return ERR_USER_VERIFICATION when a user tries to likes an event but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', like: true, :session_token => 'FAKETOKEN' }
      post '/users/likeEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

  describe 'Post #removeLike', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    end

    it 'should return SUCCESS when a user removes a like for an event succesfully' do
      @like = Like.create(:event_id => @event.id, :user_id => @user.id, :like => true)
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token }
      post '/users/removeLike.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_LIKE_EVENT when a user is unable to remove a like for an event' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token }
      post '/users/removeLike.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_LIKE_EVENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user removes a like but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser2', :session_token => @session_token}
      post '/users/removeLike.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_VERIFICATION when a user tries to remove a like but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN' }
      post '/users/removeLike.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

  describe 'Post #likeEvent?', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    end
    it 'alreadyLikedEvent return TRUE if user already liked/disliked an event' do
      @like = Like.create(:event_id => @event.id, :user_id => @user.id, :like => true)
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      parsed_body['alreadyLikedEvent'].should == true
    end

    it 'alreadyLikedEvent should return FALSE if user did not like/dislike the event' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      parsed_body['alreadyLikedEvent'].should == false
    end

    it 'should return ERR_NO_USER_EXISTS when we attempt to check if a user already liked an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser2', :session_token => @session_token}
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_VERIFICATION when we attempt to check if a user already liked an event but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN' }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

  describe 'Post #postComment', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    end

    it 'should return SUCCESS when comment is successfully posted' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :comment => 'I LOVE THIS EVENT', :session_token => @session_token}
      post '/users/postComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_POST_COMMENT when user attempts to comment an event that does not exist in the db' do
      params = { event_id: 100, facebook_id: '100000450230611', :comment => 'I LOVE THIS EVENT', :session_token => @session_token}
      post '/users/postComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_POST_COMMENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user posts a comment but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser2', :comment => 'I LOVE THIS EVENT', :session_token => @session_token}
      post '/users/postComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return SUCCESS twice when we post comments twice to the same event' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :comment => 'I LOVE THIS EVENT', :session_token => @session_token}
      post '/users/postComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      params = { event_id: @event.id, facebook_id: '100000450230611', :comment => 'I LOVE THIS EVENT AGAIN', :session_token => @session_token}
      post '/users/postComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_VERIFICATION when a user attempts to post a comment but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :comment => 'I LOVE THIS EVENT', :session_token => 'FAKETOKEN' }
      post '/users/postComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

  describe 'Post #bookmarkEvent', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    end

    it 'should return SUCCESS when bookmark is successfully created' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/bookmarkEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_BOOKMARK when user attempts to bookmark an event that does not exist in the db' do
      params = { event_id: 100, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/bookmarkEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_BOOKMARK
    end

    it 'should return ERR_NO_USER_EXISTS when a user bookmarks an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser2', :session_token => @session_token}
      post '/users/bookmarkEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_BOOKMARK when a user attempts to bookmark an event twice' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/bookmarkEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      post '/users/bookmarkEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_BOOKMARK
    end

    it 'should return ERR_USER_VERIFICATION when a user attempts to check if a user already liked an event but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN' }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

  describe 'Post #deleteEvent', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @user2 = User.create(:email => "email2@email.com", :facebook_id => '668095230', :firstname => 'Red', :lastname => 'Pin')
    end

    it 'should return SUCCESS when event is successfully deleted' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/deleteEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_DELETE_EVENT when user attempts to delete an event that does not exist in the db' do
      params = { event_id: 100, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/deleteEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_DELETE_EVENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user deletes an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser3', :session_token => @session_token}
      post '/users/deleteEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_DELETE_EVENT when a user attempts to delete an event that they do not own' do
      params = { event_id: @event.id, facebook_id: '668095230', :session_token => @session_token2}
      post '/users/deleteEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_DELETE_EVENT
    end

    it 'should return ERR_USER_VERIFICATION when a user attempts to delete an event but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN' }
      post '/users/deleteEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end


  describe 'Post #cancelEvent', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @user2 = User.create(:email => "email2@email.com", :facebook_id => '668095230', :firstname => 'Red', :lastname => 'Pin')
    end

    it 'should return SUCCESS when event is successfully canceled' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/cancelEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_CANCEL_EVENT when user attempts to cancel an event that does not exist in the db' do
      params = { event_id: 100, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/cancelEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_CANCEL_EVENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user cancel an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser3', :session_token => @session_token}
      post '/users/cancelEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_CANCEL_EVENT when a user attempts to cancel an event that they do not own' do
      params = { event_id: @event.id, facebook_id: '668095230', :session_token => @session_token2}
      post '/users/cancelEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_CANCEL_EVENT
    end

    it 'should return ERR_USER_VERIFICATION when a user attempts to cancel an event but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN' }
      post '/users/cancelEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

  describe 'Post #restoreEvent', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @user2 = User.create(:email => "email2@email.com", :facebook_id => '668095230', :firstname => 'Red', :lastname => 'Pin')
    end

    it 'should return SUCCESS when event is successfully restored' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/restoreEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_RESTORE_EVENT when user attempts to restore an event that does not exist in the db' do
      params = { event_id: 100, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/restoreEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_RESTORE_EVENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user restore an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser3', :session_token => @session_token}
      post '/users/restoreEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_RESTORE_EVENT when a user attempts to restore an event that they do not own' do
      params = { event_id: @event.id, facebook_id: '668095230', :session_token => @session_token2}
      post '/users/restoreEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_RESTORE_EVENT
    end

    it 'should return ERR_USER_VERIFICATION when a user attempts to restore an event but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN' }
      post '/users/restoreEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

  describe 'Post #removeBookmark', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @bookmark = Bookmark.create(:user_id => @user.id, :event_id => @event.id)
    end

    it 'should return SUCCESS when bookmark is successfully removed' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/removeBookmark.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_REMOVE_BOOKMARK when user attempts to remove a bookmark that does not exist in the db' do
      params = { event_id: 100, facebook_id: '100000450230611', :session_token => @session_token}
      post '/users/removeBookmark.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_REMOVE_BOOKMARK
    end

    it 'should return ERR_NO_USER_EXISTS when a user removes a bookmark but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser3', :session_token => @session_token}
      post '/users/removeBookmark.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_VERIFICATION when a user attempts to remove a bookmark but the session_token does not belong to him/her' do
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN' }
      post '/users/removeBookmark.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
    end

  end

end
