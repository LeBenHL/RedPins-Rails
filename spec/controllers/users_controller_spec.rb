require 'spec_helper'

describe UsersController do

  before(:each) do
    @session_token = 'AAAEw2AGE0JYBAMc6qqcvAIDr28wPOCskrV3O2ZAB0GpTe2ddPFddIfUKN8JtkrY50afZCimIXv6w1YNhKl4SlEnrmDB10di7a3ZB9jMLagPRaIiPwhP'
    @session_token2 = 'BAAEw2AGE0JYBAESZAmjhyg27dAxFAd9ZCU385zVMUdZAF3mgkZCCVOb23hZCXQvvYtukcv1REFDTcTJJjP9OjlsqLsgDFoznMu4UZCEpxZBOH1IOoelZAPwU'
  end

  after(:all) do
    Event.remove_all_from_index!
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
    it 'alreadyLikedEvent return TRUE if user already liked/disliked an event and tell us that the user liked the event if he/she liked it' do
      @like = Like.create(:event_id => @event.id, :user_id => @user.id, :like => true)
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      parsed_body['alreadyLikedEvent'].should == true
      parsed_body['rating'].should equal(true)
    end

    it 'alreadyLikedEvent return TRUE if user already liked/disliked an event and tell us that the user disliked the event if he/she disliked it' do
      @like = Like.create(:event_id => @event.id, :user_id => @user.id, :like => false)
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token }
      post '/users/alreadyLikedEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      parsed_body['alreadyLikedEvent'].should == true
      parsed_body['rating'].should equal(false)
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

  describe 'Post #postComment', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @user2 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @comment = Comment.create(:event_id => @event.id, :user_id => @user.id, :comment => "This is my comment");
      @comment2 = Comment.create(:event_id => @event.id, :user_id => @user2.id, :comment => "Someone else's comment");
    end

    it 'should return SUCCESS when comment is successfully deleted' do
      params = { facebook_id: '100000450230611', :comment_id => @comment.id, :session_token => @session_token}
      post '/users/removeComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
    end

    it 'should return ERR_USER_REMOVE_COMMENT when user tries deleting a comment that is not theirs' do
      params = { facebook_id: '100000450230611', :comment_id => @comment2.id , :session_token => @session_token}
      post '/users/removeComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_REMOVE_COMMENT
    end

    it 'should return ERR_USER_REMOVE_COMMENT when user tries deleting a comment that does not exist' do
      params = { facebook_id: '100000450230611', :comment_id => 100 , :session_token => @session_token}
      post '/users/removeComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_REMOVE_COMMENT
    end

    it 'should return ERR_NO_USER_EXISTS when a user posts a comment but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { facebook_id: 'testUser2', :comment_id => @comment.id, :session_token => @session_token}
      post '/users/removeComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
    end

    it 'should return ERR_USER_VERIFICATION when a user attempts to post a comment but the session_token does not belong to him/her' do
      params = { facebook_id: '100000450230611', :comment_id => @comment.id, :session_token => 'FAKETOKEN' }
      post '/users/removeComment.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
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

  describe 'Post #uploadPhoto', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    end

    it 'should return SUCCESS when photo is successfully uploaded' do
      photo = fixture_file_upload('/images/testEventImage.jpg', 'image/jpg')
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token, :photo => photo }
      post '/users/uploadPhoto', params
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      @event_image = EventImage.where(:user_id => @user.id, :event_id => @event.id)[0]
      @event_image.should_not be_nil
      @event_image.photo.should_not be_nil
      @event.event_images.length.should eq(1)
    end

    it 'should return ERR_USER_UPLOAD_PHOTO if we upload to an event that does not exist in the db' do
      photo = fixture_file_upload('/images/testEventImage.jpg', 'image/jpg')
      params = { event_id: 100, facebook_id: '100000450230611', :session_token => @session_token, :photo => photo }
      post '/users/uploadPhoto', params
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_UPLOAD_PHOTO
      @event.event_images.length.should eq(0)
    end

    it 'should return ERR_USER_UPLOAD_PHOTO if we upload a file that is not a photo' do
      photo = fixture_file_upload('/images/404.html', 'text/html')
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token, :photo => photo }
      post '/users/uploadPhoto', params
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_UPLOAD_PHOTO
      @event.event_images.length.should eq(0)
    end

    it 'should return ERR_USER_UPLOAD_PHOTO if we upload a photo larger than 5MB' do
      photo = fixture_file_upload('/images/extraLarge.jpg', 'image/jpg')
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => @session_token, :photo => photo }
      post '/users/uploadPhoto', params
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_UPLOAD_PHOTO
      @event.event_images.length.should eq(0)
    end

    it 'should return ERR_NO_USER_EXISTS when a user uploads a photo but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      photo = fixture_file_upload('/images/testEventImage.jpg', 'image/jpg')
      params = { event_id: @event.id, facebook_id: 'testUser3', :session_token => @session_token, :photo => photo}
      post '/users/uploadPhoto', params
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
      @event.event_images.length.should eq(0)
    end

    it 'should return ERR_USER_VERIFICATION when a user uploads a photo but the session_token does not belong to him/her' do
      photo = fixture_file_upload('/images/testEventImage.jpg', 'image/jpg')
      params = { event_id: @event.id, facebook_id: '100000450230611', :session_token => 'FAKETOKEN', :photo => photo}
      post '/users/uploadPhoto', params
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
      @event.event_images.length.should eq(0)
    end

  end

  describe 'Post #getBookmarks', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @user1 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @user2 = User.create(email: 'jerrychen@gmail.com', facebook_id: 2, firstname: 'Jerry', lastname: 'Chen')
      @user3 = User.create(email: 'andylee@gmail.com', facebook_id: 3, firstname: 'Andy', lastname: 'Lee')
      @user4 = User.create(email: 'ericcheong@gmail.com', facebook_id: 4, firstname: 'Eric', lastname: 'Cheong')
      @user5 = User.create(email: 'victorchang@gmail.com', facebook_id: 5, firstname: 'Victor', lastname: 'Chang')
      @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                             location: "2540 Regent St.", user_id: @user.id, url: 'www.google.com', latitude: 37.86356, longitude: -122.25787, description: "It's Victor's birthday!")

      @event2 = Event.create(title: "Ben's Bash'", start_time: DateTime.new(2012,12,2), end_time: DateTime.new(2012,12,3),
                             location: "2530 Hillegass Ave.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86418, longitude: -122.25677, description: "Ben's birthday is coming up. Remember to bring presents!")

      @event3 = Event.create(title: "Eric's BBQ'", start_time: DateTime.new(2013,3,13), end_time: DateTime.new(2013,3,14),
                             location: "2520 College Ave.", user_id: @user4.id, url: 'www.google.com', latitude: 37.86483, longitude: -122.25420, description: "Meat, Steaks, Korean BBQ. No Vegatables needed. This is a man party.")

      @event4 = Event.create(title: "Andy's Picnic'", start_time: DateTime.new(2013,2,13), end_time: DateTime.new(2013,2,14),
                             location: "2200 Fulton St..", user_id: @user3.id, url: 'www.google.com', latitude: 37.86967, longitude: -122.26588, description: "Wine, cheese, sun, and good friends. Come everybody! It'll be a great day with great weather!")

      @event5 = Event.create(title: "Jerry's Lecture'", start_time: DateTime.new(2013,4,3), end_time: DateTime.new(2013,4,4),
                             location: "2300 Oxford St..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86872, longitude: -122.26628, description: "Jerry is teaching CS170. Come if you need help with algorithms")

      @event6 = Event.create(title: "Off The Grid", start_time: DateTime.new(2013,4,27), end_time: DateTime.new(2013,4,28),
                             location: "2450 Haste St..", user_id: @user.id, url: 'www.google.com', latitude: 37.86595, longitude: -122.25908, description: "Great food! Though super expensive as fuck. I hope Korean Tacos are there!")

      @event7 = Event.create(title: "Hippie Celebration", start_time: DateTime.new(2013,4,30), end_time: DateTime.new(2013,5,1),
                             location: "2400 Bowditch Ave..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86720, longitude: -122.25654, description: "We are going to bake brownies. Bring other greens if you want.")

      @event8 = Event.create(title: "Holi Party", start_time: DateTime.new(2013,1,11), end_time: DateTime.new(2013,1,12),
                             location: "UC Berkeley.", user_id: @user3.id, url: 'www.google.com', latitude: 37.86948, longitude: -122.25969, description: "Holi Celebration at Berkeley! Buy your colors at the table this week!")

      @event9 = Event.create(title: "Danceworks Workshop", start_time: DateTime.new(2013,2,16), end_time: DateTime.new(2013,2,17),
                             location: "Lower Sproul", user_id: @user4.id, url: 'www.google.com', latitude: 37.86911, longitude: -122.26030, description: "We will be teaching Hip hop and Korean Pop right here on Sproul!")

      @event10 = Event.create(title: "Dead Poet's Society Meeting'", start_time: DateTime.new(2013,5,10), end_time: DateTime.new(2013,5,11),
                              location: "2100 Durant Ave.", user_id: @user5.id, url: 'www.google.com', latitude: 37.86669, longitude: -122.26759, description: "Read poetry. Speak poetry. Breathe poetry.")
      @user.bookmarkEvent(@event1.id)
      @user.bookmarkEvent(@event2.id)
      @user.bookmarkEvent(@event3.id)
      @user.bookmarkEvent(@event4.id)
      @user.bookmarkEvent(@event5.id)
      @user.bookmarkEvent(@event6.id)
      @user.bookmarkEvent(@event7.id)
      @user.bookmarkEvent(@event8.id)
      @user.bookmarkEvent(@event9.id)
      @user.bookmarkEvent(@event10.id)
    end

    it 'should return SUCCESS and if we ask for the 1st page of bookmarks for @user' do
      params = { facebook_id: '100000450230611', :session_token => @session_token, :page => 1 }
      post '/users/getBookmarks.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      parsed_body['next_page'].should eq(2)
      parsed_body['events'].length.should eq(6)
    end

    it 'should return SUCCESS and if we ask for the 2nd page of bookmarks for @user' do
      params = { facebook_id: '100000450230611', :session_token => @session_token, :page => 2 }
      post '/users/getBookmarks.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      parsed_body['next_page'].should be_nil
      parsed_body['events'].length.should eq(4)
    end

    it 'should return ERR_NO_USER_EXISTS when we request bookmarks for user but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { facebook_id: 'fakeUser', :session_token => @session_token, :page => 1 }
      post '/users/getBookmarks.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
      parsed_body['events'].should be_nil
      parsed_body['next_page'].should be_nil
    end

    it 'should return ERR_USER_VERIFICATION when we request bookmarks for a user but the session_token does not belong to him/her' do
      params = { facebook_id: '100000450230611', :session_token => 'FAKETOKEN', :page => 1 }
      post '/users/getBookmarks.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
      parsed_body['events'].should be_nil
      parsed_body['next_page'].should be_nil
    end

  end

  describe 'Post #getRecentEvents', :type => :request do
    before(:each) do
      @user = User.create(:email => "email@email.com", :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @user1 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @user2 = User.create(email: 'jerrychen@gmail.com', facebook_id: 2, firstname: 'Jerry', lastname: 'Chen')
      @user3 = User.create(email: 'andylee@gmail.com', facebook_id: 3, firstname: 'Andy', lastname: 'Lee')
      @user4 = User.create(email: 'ericcheong@gmail.com', facebook_id: 4, firstname: 'Eric', lastname: 'Cheong')
      @user5 = User.create(email: 'victorchang@gmail.com', facebook_id: 5, firstname: 'Victor', lastname: 'Chang')
      @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                             location: "2540 Regent St.", user_id: @user.id, url: 'www.google.com', latitude: 37.86356, longitude: -122.25787, description: "It's Victor's birthday!")

      @event2 = Event.create(title: "Ben's Bash'", start_time: DateTime.new(2012,12,2), end_time: DateTime.new(2012,12,3),
                             location: "2530 Hillegass Ave.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86418, longitude: -122.25677, description: "Ben's birthday is coming up. Remember to bring presents!")

      @event3 = Event.create(title: "Eric's BBQ'", start_time: DateTime.new(2013,3,13), end_time: DateTime.new(2013,3,14),
                             location: "2520 College Ave.", user_id: @user4.id, url: 'www.google.com', latitude: 37.86483, longitude: -122.25420, description: "Meat, Steaks, Korean BBQ. No Vegatables needed. This is a man party.")

      @event4 = Event.create(title: "Andy's Picnic'", start_time: DateTime.new(2013,2,13), end_time: DateTime.new(2013,2,14),
                             location: "2200 Fulton St..", user_id: @user3.id, url: 'www.google.com', latitude: 37.86967, longitude: -122.26588, description: "Wine, cheese, sun, and good friends. Come everybody! It'll be a great day with great weather!")

      @event5 = Event.create(title: "Jerry's Lecture'", start_time: DateTime.new(2013,4,3), end_time: DateTime.new(2013,4,4),
                             location: "2300 Oxford St..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86872, longitude: -122.26628, description: "Jerry is teaching CS170. Come if you need help with algorithms")

      @event6 = Event.create(title: "Off The Grid", start_time: DateTime.new(2013,4,27), end_time: DateTime.new(2013,4,28),
                             location: "2450 Haste St..", user_id: @user.id, url: 'www.google.com', latitude: 37.86595, longitude: -122.25908, description: "Great food! Though super expensive as fuck. I hope Korean Tacos are there!")

      @event7 = Event.create(title: "Hippie Celebration", start_time: DateTime.new(2013,4,30), end_time: DateTime.new(2013,5,1),
                             location: "2400 Bowditch Ave..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86720, longitude: -122.25654, description: "We are going to bake brownies. Bring other greens if you want.")

      @event8 = Event.create(title: "Holi Party", start_time: DateTime.new(2013,1,11), end_time: DateTime.new(2013,1,12),
                             location: "UC Berkeley.", user_id: @user3.id, url: 'www.google.com', latitude: 37.86948, longitude: -122.25969, description: "Holi Celebration at Berkeley! Buy your colors at the table this week!")

      @event9 = Event.create(title: "Danceworks Workshop", start_time: DateTime.new(2013,2,16), end_time: DateTime.new(2013,2,17),
                             location: "Lower Sproul", user_id: @user4.id, url: 'www.google.com', latitude: 37.86911, longitude: -122.26030, description: "We will be teaching Hip hop and Korean Pop right here on Sproul!")

      @event10 = Event.create(title: "Dead Poet's Society Meeting'", start_time: DateTime.new(2013,5,10), end_time: DateTime.new(2013,5,11),
                              location: "2100 Durant Ave.", user_id: @user5.id, url: 'www.google.com', latitude: 37.86669, longitude: -122.26759, description: "Read poetry. Speak poetry. Breathe poetry.")
      @user.logEvent(@event1.id)
      @user.logEvent(@event2.id)
      @user.logEvent(@event3.id)
      @user.logEvent(@event4.id)
      @user.logEvent(@event5.id)
      @user.logEvent(@event6.id)
      @user.logEvent(@event7.id)
      @user.logEvent(@event8.id)
      @user.logEvent(@event9.id)
      @user.logEvent(@event10.id)
    end

    it 'should return SUCCESS and if we ask for the 1st page of bookmarks for @user' do
      params = { facebook_id: '100000450230611', :session_token => @session_token, :page => 1 }
      post '/users/getRecentEvents.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::SUCCESS
      parsed_body['next_page'].should be_nil
      parsed_body['events'].length.should eq(10)
    end

    it 'should return ERR_NO_USER_EXISTS when we request bookmarks for user but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { facebook_id: 'fakeUser', :session_token => @session_token, :page => 1 }
      post '/users/getRecentEvents.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_NO_USER_EXISTS
      parsed_body['events'].should be_nil
      parsed_body['next_page'].should be_nil
    end

    it 'should return ERR_USER_VERIFICATION when we request bookmarks for a user but the session_token does not belong to him/her' do
      params = { facebook_id: '100000450230611', :session_token => 'FAKETOKEN', :page => 1 }
      post '/users/getRecentEvents.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == RedPins::Application::ERR_USER_VERIFICATION
      parsed_body['events'].should be_nil
      parsed_body['next_page'].should be_nil
    end

  end

end
