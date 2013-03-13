require 'spec_helper'

describe EventsController do

  ERR_NO_EVENT_EXISTS = -9


  describe 'Post #getRatings?', :type => :request do
    it 'should return the correct amount of likes an dislikes it has' do
      @user1 = User.create(:email => 'email1@email.com', :facebook_id => 'testUser1')
      @user2 = User.create(:email => 'email2@email.com', :facebook_id => 'testUser2')
      @user3 = User.create(:email => 'email3@email.com', :facebook_id => 'testUser3')
      @user4 = User.create(:email => 'email4@email.com', :facebook_id => 'testUser4')
      @user5 = User.create(:email => 'email5@email.com', :facebook_id => 'testUser5')
      @event = Event.create(:title => 'newEvent', :time => '2013-03-14', :location => 'Berkeley', :url => 'www.thEvent.com')
      Like.create(:event_id => @event.id, :user_id => @user1.id, :like => true)
      Like.create(:event_id => @event.id, :user_id => @user2.id, :like => true)
      Like.create(:event_id => @event.id, :user_id => @user3.id, :like => false)
      Like.create(:event_id => @event.id, :user_id => @user4.id, :like => false)
      Like.create(:event_id => @event.id, :user_id => @user5.id, :like => true)
      params = { event_id: @event.id }
      post '/events/getRatings.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(SUCCESS)
      parsed_body['likes'].should equal(3)
      parsed_body['dislikes'].should equal(2)
    end


    it 'should return ERR_NO_EVENT_EXISTS if we ask for a rating for an event_id that does not exist in the database' do
      params = { event_id: 1 }
      post '/events/getRatings.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(ERR_NO_EVENT_EXISTS)
    end

  end

end
