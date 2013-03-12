# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  email       :string(255)      not null
#  facebook_id :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

SUCCESS = 1
ERR_NO_USER_EXISTS = -1
ERR_USER_EXISTS = -2
ERR_BAD_EMAIL = -3
ERR_BAD_FACEBOOK_ID = -4

describe User do
  it 'adds a user into the database' do
    response = User.add('email@email.com', 'testUser')
    expect(response).to eq(SUCCESS)
  end

  it 'refuses to add a user with duplicate email' do
    User.add('email@email.com', 'testUser')
    response = User.add('email@email.com', 'anotherTestUser')
    expect(response).to eq(ERR_USER_EXISTS)
  end

  it 'refuses to add a user with a duplicate facebook id' do
    User.add('email@email.com', 'testUser')
    response = User.add('newEmail@email.com', 'testUser')
    expect(response).to eq(ERR_USER_EXISTS)
  end

  it 'refuses to add a user with an invalid email' do
    response = User.add('fakeEmail', 'testUser')
    expect(response).to eq(ERR_BAD_EMAIL)
  end

  it 'returns SUCCESS when user logins with a proper facebook id' do
    User.add('email@email.com', 'testUser')
    response = User.login('email@email.com', 'testUser')
    expect(response).to eq(SUCCESS)
  end

  it 'fails when user logins with a facebook id not recognized in the DB' do
    User.add('email@email.com', 'testUser')
    response = User.login('email@email.com', 'anotherTestUser')
    expect(response).to eq(ERR_NO_USER_EXISTS)
  end

  it 'users can like events' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    response = @user.rateEvent(@event.id, true)
    response.should equal(true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    @like.like.should equal(true)
  end

  it 'users can dislike events' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    response = @user.rateEvent(@event.id, false)
    response.should equal(true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    @like.like.should equal(false)
  end

  it 'users cannot like events that do not exist' do
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    response = @user.rateEvent(1, true)
    response.should equal(false)
  end

  it 'rateEvent? returns true if user has rated an event before' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    response = @user.rateEvent(@event.id, true)
    response.should equal(true)
    @user.rateEvent?(@event.id).should equal(true)
  end

  it 'rateEvent? returns false if user has not rated an event before' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    @user.rateEvent?(@event.id).should equal(false)
  end

  it 'getUser should return a user with the facebook_id if he/she exists' do
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    @user.should_not be_nil
    @user.facebook_id.should eq('testUser')
  end

  it 'getUser should return nil if a user with a facebook_id does not exist' do
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser2')
    @user.should be_nil
  end

  it 'getRatingForEvent should return like object of an event if a user has liked that event before' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    @user.rateEvent(@event.id, true)
    @like = @user.getRatingForEvent(@event.id)
    @like.should_not be_nil
    @like.event_id.should equal(@event.id)
    @like.user_id.should equal(@user.id)
    @like.like.should equal(true)
  end

  it 'getRatingForEvent should return nil if a user has not liked that event before' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    @like = @user.getRatingForEvent(@event.id)
    @like.should be_nil
  end

  it 'deleteRatingForEvent should return true if like object was successfully deleted' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    @user.rateEvent(@event.id, true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should_not be_nil
    response = @user.deleteRatingForEvent(@event.id)
    response.should equal(true)
    @like = Like.where(:user_id => @user.id, :event_id => @event.id)[0]
    @like.should be_nil
  end

  it 'deleteRatingForEvent should return false if user has not rating event before uet' do
    @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
    User.add('email@email.com', 'testUser')
    @user = User.getUser('testUser')
    response = @user.deleteRatingForEvent(@event.id)
    response.should equal(false)
  end

end
