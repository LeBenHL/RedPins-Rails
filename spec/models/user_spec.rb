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
    @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com')
    @response = User.add('email@email.com', 'testUser', 'Red', 'Pin')
  end

  it 'adds a user into the database' do
    expect(@response).to eq(RedPins::Application::SUCCESS)
  end

  it 'refuses to add a user with duplicate email' do
    response = User.add('email@email.com', 'anotherTestUser','Red', 'Pin')
    expect(response).to eq(RedPins::Application::ERR_USER_EXISTS)
  end

  it 'refuses to add a user with a duplicate facebook id' do
    response = User.add('newEmail@email.com', 'testUser','Red', 'Pin')
    expect(response).to eq(RedPins::Application::ERR_USER_EXISTS)
  end

  it 'refuses to add a user with an invalid email' do
    response = User.add('fakeEmail', 'testUser','Red', 'Pin')
    expect(response).to eq(RedPins::Application::ERR_BAD_EMAIL)
  end

  it 'returns SUCCESS when user logins with a proper facebook id' do
    response = User.login('testUser')
    expect(response).to eq(RedPins::Application::SUCCESS)
  end

  it 'fails when user logins with a facebook id not recognized in the DB' do
    response = User.login('anotherTestUser')
    expect(response).to eq(RedPins::Application::ERR_NO_USER_EXISTS)
  end

  it 'users can like events' do
    @user = User.getUser('testUser')
    response = @user.likeEvent(@event.id, true)
    response.should equal(true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    @like.like.should equal(true)
  end

  it 'users can dislike events' do
    @user = User.getUser('testUser')
    response = @user.likeEvent(@event.id, false)
    response.should equal(true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    @like.like.should equal(false)
  end

  it 'users cannot like events that do not exist' do
    @user = User.getUser('testUser')
    response = @user.likeEvent(100, true)
    response.should equal(false)
  end

  it 'likeEvent? returns true if user has rated an event before' do
    @user = User.getUser('testUser')
    response = @user.likeEvent(@event.id, true)
    response.should equal(true)
    @user.likeEvent?(@event.id).should equal(true)
  end

  it 'likeEvent? returns false if user has not rated an event before' do
    @user = User.getUser('testUser')
    @user.likeEvent?(@event.id).should equal(false)
  end

  it 'getUser should return a user with the facebook_id if he/she exists' do
    @user = User.getUser('testUser')
    @user.should_not be_nil
    @user.facebook_id.should eq('testUser')
  end

  it 'getUser should return nil if a user with a facebook_id does not exist' do
    @user = User.getUser('testUser2')
    @user.should be_nil
  end

  it 'getRatingForEvent should return like object of an event if a user has liked that event before' do
    @user = User.getUser('testUser')
    @user.likeEvent(@event.id, true)
    @like = @user.getRatingForEvent(@event.id)
    @like.should_not be_nil
    @like.event_id.should equal(@event.id)
    @like.user_id.should equal(@user.id)
    @like.like.should equal(true)
  end

  it 'getRatingForEvent should return nil if a user has not liked that event before' do
    @user = User.getUser('testUser')
    @like = @user.getRatingForEvent(@event.id)
    @like.should be_nil
  end

  it 'removeLike should return true if like object was successfully deleted' do
    @user = User.getUser('testUser')
    @user.likeEvent(@event.id, true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    response = @user.removeLike(@event.id)
    response.should equal(true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should be_nil
  end

  it 'removeLike should return false if user has not rating event before uet' do
    @user = User.getUser('testUser')
    response = @user.removeLike(@event.id)
    response.should equal(false)
  end

  it 'postComment should return true if a comment was successfully posted to an event' do
    @user = User.getUser('testUser')
    response = @user.postComment(@event.id, "I LOVE THIS EVENT")
    @comment = Comment.where(:user_id => @user.id, :event_id => @event.id)[0]
    @comment.should_not be_nil
    response.should equal(true)
  end

  it 'postComment should return false if a user tried commenting an event that does not exist in the db' do
    @user = User.getUser('testUser')
    response = @user.postComment(100, "I LOVE THIS EVENT")
    response.should equal(false)
  end

end
