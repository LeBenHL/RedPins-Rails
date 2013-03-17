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

  it 'likeEvent? returns true if user has rated an event before' do
    @user = User.getUser('100000450230611')
    response = @user.likeEvent(@event.id, true)
    response.should equal(RedPins::Application::SUCCESS)
    @user.likeEvent?(@event.id).should equal(true)
  end

  it 'likeEvent? returns false if user has not rated an event before' do
    @user = User.getUser('100000450230611')
    @user.likeEvent?(@event.id).should equal(false)
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

end
