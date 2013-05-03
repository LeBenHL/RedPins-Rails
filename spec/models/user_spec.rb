# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  email       :string(255)      not null
#  facebook_id :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  firstname   :string(255)
#  lastname    :string(255)
#

require 'spec_helper'

describe User do

  before(:each) do
    @session_token = 'AAAEw2AGE0JYBAMc6qqcvAIDr28wPOCskrV3O2ZAB0GpTe2ddPFddIfUKN8JtkrY50afZCimIXv6w1YNhKl4SlEnrmDB10di7a3ZB9jMLagPRaIiPwhP'
    @response = User.add('email@email.com', '100000450230611', 'Red', 'Pin')
    @user = User.where(:facebook_id => '100000450230611')[0]
    @event = Event.create!(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
  end

  after(:all) do
    Event.remove_all_from_index!
  end

  it 'adds a user into the database' do
    expect(@response).to eq(RedPins::Application::SUCCESS)
  end

  it 'refuses to add a user with a duplicate facebook id' do
    response = User.add('newEmail@email.com', '100000450230611','Red', 'Pin')
    expect(response).to eq(RedPins::Application::ERR_USER_EXISTS)
  end

  it 'refuses to add a user with an invalid email' do
    response = User.add('fakeEmail', '100000450230611','Red', 'Pin')
    expect(response).to eq(RedPins::Application::ERR_BAD_EMAIL)
  end

  it 'refuses to add a user with a empty email' do
    response = User.add('', '100000450230611','Red', 'Pin')
    expect(response).to eq(RedPins::Application::ERR_BAD_EMAIL)
  end

  it 'refuses to add a user with a empty facebook_id' do
    response = User.add('newEmail@email.com', '','Red', 'Pin')
    expect(response).to eq(RedPins::Application::ERR_BAD_FACEBOOK_ID)
  end

  it 'returns SUCCESS when user logins with a proper facebook id' do
    response = User.login('100000450230611', @session_token)
    expect(response).to eq(RedPins::Application::SUCCESS)
  end

  it 'returns ERR_NO_USER_EXISTS when user logins with a facebook id not recognized in the DB' do
    response = User.login('anotherTestUser', @session_token)
    expect(response).to eq(RedPins::Application::ERR_NO_USER_EXISTS)
  end

  it 'RETURNS ERR_USER_VERIFICATION when user logins with a session_token that does not belong to the facebook user of facebook_id' do
    response = User.login('100000450230611', 'FAKESESSIONTOKEN')
    expect(response).to eq(RedPins::Application::ERR_USER_VERIFICATION)
  end

  it 'RETURNS SUCCESS when we verify with a session_token that does belong to the facebook user of facebook_id' do
    response = User.login('100000450230611', @session_token)
    expect(response).to eq(RedPins::Application::SUCCESS)
  end

  it 'RETURNS ERR_USER_VERIFICATION when we verify a session_token that does not belong to the facebook user of facebook_id' do
    response = User.verify('100000450230611', 'FAKESESSIONTOKEN')
    expect(response).to eq(RedPins::Application::ERR_USER_VERIFICATION)
  end

  it 'users can like events' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent(@event.id, true)
    response.should equal(RedPins::Application::SUCCESS)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    @like.like.should equal(true)
  end

  it 'users can dislike events' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent(@event.id, false)
    response.should equal(RedPins::Application::SUCCESS)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    @like.like.should equal(false)
  end

  it 'users cannot like and dislike events multiple times' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent(@event.id, false)
    response.should equal(RedPins::Application::SUCCESS)
    response = @user.likeEvent(@event_id, true)
    response.should equal(RedPins::Application::ERR_USER_LIKE_EVENT)
  end

  it 'users cannot like events that do not exist' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent(100, true)
    response.should equal(RedPins::Application::ERR_USER_LIKE_EVENT)
  end

  it 'likeEvent? confirms if user has rated an event before and he/she liked it' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent(@event.id, true)
    response.should equal(RedPins::Application::SUCCESS)
    response = @user.likeEvent?(@event.id)
    response[:alreadyLikedEvent].should equal(true)
    response[:like].should equal(true)
  end

  it 'likeEvent? confirms if user has rated an event before and he/she doliked it' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent(@event.id, false)
    response.should equal(RedPins::Application::SUCCESS)
    response = @user.likeEvent?(@event.id)
    response[:alreadyLikedEvent].should equal(true)
    response[:like].should equal(false)
  end

  it 'likeEvent? returns false if user has not rated an event before' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent?(@event.id)
    response[:alreadyLikedEvent].should equal(false)
  end

  it 'getUser should return a user with the facebook_id if he/she exists' do
    @user = User.getUser('100000450230611')
    @user.should_not be_nil
    @user.facebook_id.should eq('100000450230611')
  end

  it 'getUser should return nil if a user with a facebook_id does not exist' do
    @user = User.getUser('testUser2')
    @user.should be_nil
  end

  it 'getRatingForEvent should return like object of an event if a user has liked that event before' do
    @user = User.getUser('100000450230611')
    @user.likeEvent(@event.id, true)
    @like = @user.getRatingForEvent(@event.id)
    @like.should_not be_nil
    @like.event_id.should equal(@event.id)
    @like.user_id.should equal(@user.id)
    @like.like.should equal(true)
  end

  it 'getRatingForEvent should return nil if a user has not liked that event before' do
    @user = User.getUser('100000450230611')
    @like = @user.getRatingForEvent(@event.id)
    @like.should be_nil
  end

  it 'removeLike should return true if like object was successfully deleted' do
    @user = User.getUser('100000450230611')
    @user.likeEvent(@event.id, true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    response = @user.removeLike(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should be_nil
  end

  it 'removeLike should return false if user has not rating event before uet' do
    @user = User.getUser('100000450230611')
    response = @user.removeLike(@event.id)
    response.should equal(RedPins::Application::ERR_USER_LIKE_EVENT)
  end

  it 'postComment should return true if a comment was successfully posted to an event' do
    @user = User.getUser('100000450230611')
    response = @user.postComment(@event.id, "I LOVE THIS EVENT")
    @comment = Comment.where(:user_id => @user.id, :event_id => @event.id)[0]
    @comment.should_not be_nil
    response.should equal(RedPins::Application::SUCCESS)
  end

  it 'postComment should return false if a user tried commenting an event that does not exist in the db' do
    @user = User.getUser('100000450230611')
    response = @user.postComment(100, "I LOVE THIS EVENT")
    response.should equal(RedPins::Application::ERR_USER_POST_COMMENT)
  end

  it 'postComment should allow a user to post twice to the same event' do
    response = @user.postComment(@event.id, "I LOVE THIS EVENT")
    @comment = Comment.where(:user_id => @user.id, :event_id => @event.id)[0]
    @comment.should_not be_nil
    response.should equal(RedPins::Application::SUCCESS)
    response = @user.postComment(@event.id, "I LOVE THIS EVENT AGAIN")
    @comment = Comment.where(:user_id => @user.id, :event_id => @event.id)[1]
    @comment.should_not be_nil
    response.should equal(RedPins::Application::SUCCESS)
  end

  it 'bookmarkEvent should return true if a bookmark was successfully created between a user and event' do
    @user = User.getUser('100000450230611')
    response = @user.bookmarkEvent(@event.id)
    @bookmark = Bookmark.where(:user_id => @user.id, :event_id => @event.id)[0]
    @bookmark.should_not be_nil
    response.should equal(RedPins::Application::SUCCESS)
  end

  it 'bookmarkEvent should return false if a user tried bookmarking an event that does not exist in the db' do
    @user = User.getUser('100000450230611')
    response = @user.bookmarkEvent(100)
    response.should equal(RedPins::Application::ERR_USER_BOOKMARK)
  end

  it 'users should not be able to bookmark the same event twice' do
    @user = User.getUser('100000450230611')
    response = @user.bookmarkEvent(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    response = @user.bookmarkEvent(@event.id)
    response.should equal(RedPins::Application::ERR_USER_BOOKMARK)
  end

  it 'deleteEvent should return true if deletion was successful' do
    @user = User.getUser('100000450230611')
    response = @user.deleteEvent(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    @event2 = Event.where(:id => @event.id)[0]
    @event2.should be_nil
  end

  it 'deleteEvent should destroy the associated bookmark' do
    @user = User.getUser('100000450230611')
    @bookmark = Bookmark.create(:event_id => @event.id, :user_id => @user.id)
    @bookmark.should_not be_nil
    response = @user.deleteEvent(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    lambda {Bookmark.find(@bookmark.id)}.should raise_error
  end

  it 'deleteEvent should destroy the associated recent event log' do
    @user = User.getUser('100000450230611')
    @log = RecentEvent.create(:event_id => @event.id, :user_id => @user.id)
    @log.should_not be_nil
    response = @user.deleteEvent(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    lambda {RecentEvent.find(@log.id)}.should raise_error
  end

  it 'deleteEvent should return false if a user tried deleting an event that does not exist in the db' do
    @user = User.getUser('100000450230611')
    response = @user.deleteEvent(100)
    response.should equal(RedPins::Application::ERR_USER_DELETE_EVENT)
  end

  it 'deleteEvent should return false if a user tries deleting an event they do not own' do
    @user2 = User.create(:email => "email2@email.com", :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
    response = @user2.deleteEvent(@event.id)
    response.should equal(RedPins::Application::ERR_USER_DELETE_EVENT)
    @event2 = Event.where(:id => @event.id)[0]
    @event2.should_not be_nil
  end

  it 'cancelEvent should return true if canceling was successful' do
    @user = User.getUser('100000450230611')
    response = @user.cancelEvent(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    @event2 = Event.where(:id => @event.id)[0]
    @event2.canceled.should equal(true)
  end

  it 'cancelEvent should return false if a user tried canceling an event that does not exist in the db' do
    @user = User.getUser('100000450230611')
    response = @user.cancelEvent(100)
    response.should equal(RedPins::Application::ERR_USER_CANCEL_EVENT)
  end

  it 'cancelEvent should return false if a user tries canceling an event they do not own' do
    @user2 = User.create(:email => "email2@email.com", :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
    response = @user2.cancelEvent(@event.id)
    response.should equal(RedPins::Application::ERR_USER_CANCEL_EVENT)
    @event2 = Event.where(:id => @event.id)[0]
    @event2.canceled.should equal(false)
  end

  it 'restoreEvent should return true if restoring was successful' do
    @user = User.getUser('100000450230611')
    @user.cancelEvent(@event.id)
    response = @user.restoreEvent(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    @event2 = Event.where(:id => @event.id)[0]
    @event2.canceled.should equal(false)
  end

  it 'restoreEvent should return false if a user tried restoring an event that does not exist in the db' do
    @user = User.getUser('100000450230611')
    @user.cancelEvent(@event.id)
    @event.delete
    response = @user.restoreEvent(@event.id)
    response.should equal(RedPins::Application::ERR_USER_RESTORE_EVENT)
  end

  it 'restoreEvent should return false if a user tries restoring an event they do not own' do
    @user2 = User.create(:email => "email2@email.com", :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
    @user.cancelEvent(@event.id)
    response = @user2.restoreEvent(@event.id)
    response.should equal(RedPins::Application::ERR_USER_RESTORE_EVENT)
    @event2 = Event.where(:id => @event.id)[0]
    @event2.canceled.should equal(true)
  end

  it 'removeBookmark should return SUCCESS if removing bookmark was successful' do
    @user = User.getUser('100000450230611')
    @bookmark = Bookmark.create(:user_id => @user.id, :event_id => @event.id)
    @bookmark.should_not be_nil
    response = @user.removeBookmark(@event.id)
    response.should equal(RedPins::Application::SUCCESS)
    @bookmark = Bookmark.where(:user_id => @user.id, :event_id => @event.id)
    @event2.should be_nil
  end

  it 'removeBookmark should return ERR_USER_REMOVE_BOOKMARK if a user tried removing a bookmark that does not exist in the db' do
    @user = User.getUser('100000450230611')
    response = @user.removeBookmark(100)
    response.should equal(RedPins::Application::ERR_USER_REMOVE_BOOKMARK)
  end

  it 'uploadPhoto should return SUCCESS if upload was successful with correct caption' do
    @user = User.getUser('100000450230611')
    photo = File.new('public/testEventImage.jpg', 'rb')
    caption = "This is the caption"
    response = @user.uploadPhoto(@event.id, photo, caption)
    response[:errCode].should equal(RedPins::Application::SUCCESS)
    @event_image = EventImage.where(:user_id => @user.id, :event_id => @event.id)[0]
    @event_image.should_not be_nil
    @event_image.photo.should_not be_nil
    @event_image.caption.should eq(caption)
    @event.event_images.length.should eq(1)
  end

  it 'uploadPhoto should return ERR_USER_UPLOAD_PHOTO if we upload to an event that does not exist in the db' do
    @user = User.getUser('100000450230611')
    photo = File.new('public/testEventImage.jpg', 'rb')
    caption = "This is the caption"
    response = @user.uploadPhoto(100, photo, caption)
    response[:errCode].should equal(RedPins::Application::ERR_USER_UPLOAD_PHOTO)
    @event.event_images.length.should eq(0)
  end

  it 'uploadPhoto should return ERR_USER_UPLOAD_PHOTO if we upload a file that is not a photo' do
    @user = User.getUser('100000450230611')
    photo = File.new('public/404.html', 'rb')
    caption = "This is the caption"
    response = @user.uploadPhoto(@event.id, photo, caption)
    response[:errCode].should equal(RedPins::Application::ERR_USER_UPLOAD_PHOTO)
    @event.event_images.length.should eq(0)
  end

  it 'uploadPhoto should return ERR_USER_UPLOAD_PHOTO if we upload a photo larger than 5MB' do
    @user = User.getUser('100000450230611')
    photo = File.new('public/extraLarge.jpg', 'rb')
    caption = "This is the caption"
    response = @user.uploadPhoto(@event.id, photo, caption)
    response[:errCode].should equal(RedPins::Application::ERR_USER_UPLOAD_PHOTO)
    @event.event_images.length.should eq(0)
  end

  describe 'Get Bookmarks' do
    before(:each) do
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

    it 'getBookmarks should return the first page of 5 bookmarks' do
      response = @user.getBookmarks(1, 5)
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      bookmarks = Bookmark.where(:user_id => @user.id).order("created_at DESC").limit(5).offset(0)
      bookmarks.each do |bookmark|
        event = bookmark.event
        attributes = event.getAttributes(@user.id)
        response[:events].should include(attributes)
      end
      response[:events].length.should eq(5)
      response[:next_page].should eq(2)
    end


    it 'getBookmarks should return the second page of 5 bookmarks' do
      response = @user.getBookmarks(2, 5)
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      bookmarks = Bookmark.where(:user_id => @user.id).order("created_at DESC").limit(5).offset(5)
      bookmarks.each do |bookmark|
        event = bookmark.event
        attributes =  event.getAttributes(@user.id)
        response[:events].should include(attributes)
      end
      response[:events].length.should eq(5)
      response[:next_page].should be_nil
    end

  end

  describe 'removeComment' do

    before(:each) do
      @user2 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @comment = Comment.create(:event_id => @event.id, :user_id => @user.id, :comment => "This is my comment");
      @comment2 = Comment.create(:event_id => @event.id, :user_id => @user2.id, :comment => "Someone else's comment");
    end

    it 'should remove a comment if comment exists and it belongs to me' do
      @comment.should_not be_nil
      @comment2.should_not be_nil
      response = @user.removeComment(@comment.id);
      response.should eq(RedPins::Application::SUCCESS);
      expect { Comment.find(@comment.id) }.to raise_error
    end

    it 'should not remove a comment if comment exists but belongs to someone else' do
      @comment.should_not be_nil
      @comment2.should_not be_nil
      response = @user.removeComment(@comment2.id);
      response.should eq(RedPins::Application::ERR_USER_REMOVE_COMMENT);
      Comment.find(@comment.id).should_not be_nil
      Comment.find(@comment2.id).should_not be_nil
    end

    it 'should return ERR_USER_REMOVE_COMMENT if comment does not exists at all' do
      @comment.should_not be_nil
      @comment2.should_not be_nil
      response = @user.removeComment(100);
      response.should eq(RedPins::Application::ERR_USER_REMOVE_COMMENT)
      Comment.find(@comment.id).should_not be_nil
      Comment.find(@comment2.id).should_not be_nil
    end

  end


  describe 'logEvent' do

    before(:each) do
      @user1 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                             location: "2540 Regent St.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86356, longitude: -122.25787, description: "It's Victor's birthday!")

      @event2 = Event.create(title: "Ben's Bash'", start_time: DateTime.new(2012,12,2), end_time: DateTime.new(2012,12,3),
                             location: "2530 Hillegass Ave.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86418, longitude: -122.25677, description: "Ben's birthday is coming up. Remember to bring presents!")
    end

    it 'should Log both events when we ask to log them' do
      @log1 = @user1.logEvent(@event1.id)
      @log2 = @user1.logEvent(@event2.id)
      @log1.should_not be_nil
      @log2.should_not be_nil
      @user1.recent_events.count.should eq(2)
      RecentEvent.find(@log1.id).updated_at.should <  RecentEvent.find(@log2.id).updated_at
    end

    it 'should Log both events when we ask to log them and put event1 as more recent than event2 if we log event1 twice' do
      @log1 = @user1.logEvent(@event1.id)
      @log2 = @user1.logEvent(@event2.id)
      @log3 = @user1.logEvent(@event1.id)
      @log1.should_not be_nil
      @log2.should_not be_nil
      @log3.should_not be_nil
      @user1.recent_events.count.should eq(2)
      RecentEvent.find(@log1.id).updated_at.should >  RecentEvent.find(@log2.id).updated_at
      RecentEvent.find(@log3.id).updated_at.should >  RecentEvent.find(@log2.id).updated_at
    end

  end


  describe 'getRecentEvents' do

    before(:each) do
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

    it 'should return 5 most recent events that I logged' do
      response = @user.getRecentEvents(1, 5)
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      logs = RecentEvent.where(:user_id => @user.id).order("updated_at DESC").limit(5).offset(0)
      logs.each do |log|
        event = log.event
        attributes = event.getAttributes(@user.id)
        response[:events].should include(attributes)
      end
      response[:events].length.should eq(5)
      response[:next_page].should eq(2)
    end

    it 'should return the next 5 most recent events that I logged with no next page' do
      response = @user.getRecentEvents(2, 5)
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      logs = RecentEvent.where(:user_id => @user.id).order("updated_at DESC").limit(5).offset(5)
      logs.each do |log|
        event = log.event
        attributes = event.getAttributes(@user.id)
        response[:events].should include(attributes)
      end
      response[:events].length.should eq(5)
      response[:next_page].should be_nil
    end

  end
  
  describe 'getMyEvents' do
    before(:each) do
      @user1 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @user2 = User.create(email: 'jerrychen@gmail.com', facebook_id: 2, firstname: 'Jerry', lastname: 'Chen')
      @user3 = User.create(email: 'andylee@gmail.com', facebook_id: 3, firstname: 'Andy', lastname: 'Lee')
      @user4 = User.create(email: 'ericcheong@gmail.com', facebook_id: 4, firstname: 'Eric', lastname: 'Cheong')
      @user5 = User.create(email: 'victorchang@gmail.com', facebook_id: 5, firstname: 'Victor', lastname: 'Chang')
      @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                             location: "2540 Regent St.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86356, longitude: -122.25787, description: "It's Victor's birthday!")

      @event2 = Event.create(title: "Ben's Bash'", start_time: DateTime.new(2012,12,2), end_time: DateTime.new(2012,12,3),
                             location: "2530 Hillegass Ave.", user_id: @user2.id, url: 'www.google.com', latitude: 37.86418, longitude: -122.25677, description: "Ben's birthday is coming up. Remember to bring presents!")

      @event3 = Event.create(title: "Eric's BBQ'", start_time: DateTime.new(2013,3,13), end_time: DateTime.new(2013,3,14),
                             location: "2520 College Ave.", user_id: @user2.id, url: 'www.google.com', latitude: 37.86483, longitude: -122.25420, description: "Meat, Steaks, Korean BBQ. No Vegatables needed. This is a man party.")

      @event4 = Event.create(title: "Andy's Picnic'", start_time: DateTime.new(2013,2,13), end_time: DateTime.new(2013,2,14),
                             location: "2200 Fulton St..", user_id: @user3.id, url: 'www.google.com', latitude: 37.86967, longitude: -122.26588, description: "Wine, cheese, sun, and good friends. Come everybody! It'll be a great day with great weather!")

      @event5 = Event.create(title: "Jerry's Lecture'", start_time: DateTime.new(2013,4,3), end_time: DateTime.new(2013,4,4),
                             location: "2300 Oxford St..", user_id: @user3.id, url: 'www.google.com', latitude: 37.86872, longitude: -122.26628, description: "Jerry is teaching CS170. Come if you need help with algorithms")

      @event6 = Event.create(title: "Off The Grid", start_time: DateTime.new(2013,4,27), end_time: DateTime.new(2013,4,28),
                             location: "2450 Haste St..", user_id: @user3.id, url: 'www.google.com', latitude: 37.86595, longitude: -122.25908, description: "Great food! Though super expensive as fuck. I hope Korean Tacos are there!")

      @event7 = Event.create(title: "Hippie Celebration", start_time: DateTime.new(2013,4,30), end_time: DateTime.new(2013,5,1),
                             location: "2400 Bowditch Ave..", user_id: @user4.id, url: 'www.google.com', latitude: 37.86720, longitude: -122.25654, description: "We are going to bake brownies. Bring other greens if you want.")

      @event8 = Event.create(title: "Holi Party", start_time: DateTime.new(2013,1,11), end_time: DateTime.new(2013,1,12),
                             location: "UC Berkeley.", user_id: @user4.id, url: 'www.google.com', latitude: 37.86948, longitude: -122.25969, description: "Holi Celebration at Berkeley! Buy your colors at the table this week!")

      @event9 = Event.create(title: "Danceworks Workshop", start_time: DateTime.new(2013,2,16), end_time: DateTime.new(2013,2,17),
                             location: "Lower Sproul", user_id: @user4.id, url: 'www.google.com', latitude: 37.86911, longitude: -122.26030, description: "We will be teaching Hip hop and Korean Pop right here on Sproul!")

      @event10 = Event.create(title: "Dead Poet's Society Meeting'", start_time: DateTime.new(2013,5,10), end_time: DateTime.new(2013,5,11),
                              location: "2100 Durant Ave.", user_id: @user4.id, url: 'www.google.com', latitude: 37.86669, longitude: -122.26759, description: "Read poetry. Speak poetry. Breathe poetry.")
    end
    
    it 'getMyEvents should return the first page of 4 events' do
      response = @user4.getMyEvents(1, 5)
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      myEvents = Event.where(:user_id => @user4.id).order("created_at DESC").limit(5).offset(0)
      myEvents.each do |event|
        attributes = event.getAttributes(@user4.id)
        response[:myEvents].should include(attributes)
      end
      response[:myEvents].length.should eq(4)
      response[:next_myEvent_page].should eq(nil)
    end
    
    it 'getMyEvents should return the second page of 1 event' do
      response = @user3.getMyEvents(2, 1)
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      myEvents = Event.where(:user_id => @user3.id).order("created_at DESC").limit(1).offset(1)
      myEvents.each do |event|
        attributes = event.getAttributes(@user3.id)
        response[:myEvents].should include(attributes)
      end
      response[:myEvents].length.should eq(1)
      response[:next_myEvent_page].should eq(3)
    end
    
  end

  describe 'getSimpleRecommendations' do
    before(:each) do
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
      # events 1, 6 are created by user
      # event 2 is created by user1
      # events 3, 9 are created by user4
      # events 4, 8 are created by user3
      # event 5 is created by user2
      # event 7 is created by user2
      # event 10 is created by user5
    end

    after(:all) do

    end

    it 'getSimpleRecommendations: returns all events by the same creators of user liked events' do
      # should return events 2, 3, 4, 8, 9
      response = @user.likeEvent(@event1.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event2.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event3.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event4.id, true)
      response.should equal(RedPins::Application::SUCCESS)

      response = @user.getSimpleRecommendations()
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      event_ids = []
      response[:events].each do |event_recommended|
        event_ids.push(event_recommended['id'])
      end
      event_ids.should =~ [@event2.id, @event3.id, @event4.id, @event8.id, @event9.id]
    end

    it 'getSimpleRecommendations: excludes events that user dislikes' do
      # should return events 2, 3, 4, 9 if user dislikes event 8
      response = @user.likeEvent(@event2.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event3.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event4.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event8.id, false)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.getSimpleRecommendations()
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      event_ids = []
      response[:events].each do |event_recommended|
        event_ids.push(event_recommended['id'])
      end
      # Recommending event 8 depends on user liking event 4, so event 4 remains
      event_ids.should =~ [@event2.id, @event3.id, @event4.id, @event9.id]
    end

    it 'getSimpleRecommendations: if last liked event for a creator gets disliked, exclude all events by that creator' do
      # should return events 2, 3, 9 if user dislikes event 4
      response = @user.likeEvent(@event2.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event3.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event4.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.removeLike(@event4.id)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event4.id, false)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.getSimpleRecommendations()
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      event_ids = []
      response[:events].each do |event_recommended|
        event_ids.push(event_recommended['id'])
      end
      # Since event 8 depends on user liking event 4, event 8 is no longer recommended
      event_ids.should =~ [@event2.id, @event3.id, @event9.id]
    end

    it 'getSimpleRecommendations: make sure there aren\'t duplicate recommendations when user likes two events from same creator' do
      # should return events 3, 9 w/o duplicates if user likes both events 3, 9
      response = @user.likeEvent(@event3.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.likeEvent(@event9.id, true)
      response.should equal(RedPins::Application::SUCCESS)
      response = @user.getSimpleRecommendations()
      response[:errCode].should eq(RedPins::Application::SUCCESS)
      event_ids = []
      response[:events].each do |event_recommended|
        event_ids.push(event_recommended['id'])
      end
      event_ids.should =~ [@event3.id, @event9.id]
    end
  end
end
