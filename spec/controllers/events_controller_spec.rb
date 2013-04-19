require 'spec_helper'

describe EventsController do

  before(:each) do
    @session_token = 'AAAEw2AGE0JYBAMc6qqcvAIDr28wPOCskrV3O2ZAB0GpTe2ddPFddIfUKN8JtkrY50afZCimIXv6w1YNhKl4SlEnrmDB10di7a3ZB9jMLagPRaIiPwhP'
    @session_token2 = 'BAAEw2AGE0JYBAESZAmjhyg27dAxFAd9ZCU385zVMUdZAF3mgkZCCVOb23hZCXQvvYtukcv1REFDTcTJJjP9OjlsqLsgDFoznMu4UZCEpxZBOH1IOoelZAPwU'
  end

  after(:all) do
    Event.remove_all_from_index!
  end

  describe 'Event #getRatings', :type => :request do
    before(:each) do
      @user = User.create(:email => 'email@email.com', :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
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

  describe 'Event #add', :type => :request do
    before(:each) do
      @user = User.create(:email => 'email@email.com', :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
    end

    it 'should return SUCCESS upon creation of event' do
      params = { facebook_id: @user.facebook_id, session_token: @session_token, title: "Test 001: New Event", start_time: "2013-06-09T10:11:31Z" , end_time: "2013-06-09T12:30:00Z", location: "Berkeley", url: "yelp.com" }
      post '/events/add.json', params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
    end

    it 'should return ERR_BAD_TITLE when title is missing' do
      params = { facebook_id: @user.facebook_id, session_token: @session_token, start_time: "2013-06-09T10:11:31Z" , end_time: "2013-06-09T12:30:00Z", location: "Berkeley", url: "yelp.com" }
      post '/events/add.json', params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_BAD_TITLE)
    end
    
    it 'should return ERR_BAD_START_TIME when start_time is invalid' do
      params = { facebook_id: @user.facebook_id, session_token: @session_token, title: "Test 003: New Event", start_time: "" , end_time: "2013-06-09T12:30:00Z", location: "Berkeley", url: "yelp.com" }
      post '/events/add.json', params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_BAD_START_TIME)
    end

    it 'should return ERR_BAD_END_TIME when end_time is invalid' do
      params = { facebook_id: @user.facebook_id, session_token: @session_token, title: "Test 003: New Event", end_time: "" , start_time: "2013-06-09T12:30:00Z", location: "Berkeley", url: "yelp.com" }
      post '/events/add.json', params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_BAD_END_TIME)
    end

    it 'should return ERR_BAD_LOCATION when location is missing' do
      params = { facebook_id: @user.facebook_id, session_token: @session_token, title: "Test 003: New Event", start_time: "2013-06-08T12:00:00Z" , end_time: "2013-06-09T12:30:00Z", url: "yelp.com" }
      post '/events/add.json', params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_BAD_LOCATION)
    end

    it 'should return ERR_EVENT_CREATION when location is invalid' do
      params = { facebook_id: @user.facebook_id, session_token: @session_token, title: "Test 003: New Event", start_time: "2013-06-08T12:00:00Z" , end_time: "2013-06-09T12:30:00Z", location: "AZN GHETTO WONDERLAND", url: "yelp.com" }
      post '/events/add.json', params.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_EVENT_CREATION)
    end
  end

  describe 'Event #getComments', :type => :request do
    before(:each) do
      @user = User.create(:email => 'email@email.com', :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
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

  describe 'Event #getEvent', :type => :request do
    before(:each) do
      @user1 = User.create(:email => 'email1@email.com', :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @user2 = User.create(:email => 'email2@email.com', :facebook_id => '668095230', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user1.id)
    end

    it 'should return SUCCESS if retrieve a valid event and set owner as true if owner of the event does the API call' do
      params = { event_id: @event.id, facebook_id: '100000450230611', session_token: @session_token }
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['event']['id'].should equal(@event.id)
      parsed_body['event']['owner'].should equal(true)
    end

    it 'should return SUCCESS if retrieve a valid event and set owner as false if non-owner of the event does the API call' do
      params = { event_id: @event.id, facebook_id: '668095230', session_token: @session_token2 }
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['event']['id'].should equal(@event.id)
      parsed_body['event']['owner'].should equal(false)
    end


    it 'should return ERR_NO_EVENT_EXISTS if we ask for an event that does not exist in the database' do
      params = { event_id: 100, facebook_id: '100000450230611', session_token: @session_token }
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_EVENT_EXISTS)
    end

    it 'should return ERR_NO_USER_EXISTS when a user asks an event but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { event_id: @event.id, facebook_id: 'testUser3', session_token: @session_token}
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_USER_EXISTS)
    end

    it 'should return ERR_USER_VERIFICATION when a user asks an event but the session token does not belong to the user' do
      params = { event_id: @event.id, facebook_id: '100000450230611', session_token: 'FAKETOKEN'}
      post '/events/getEvent.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_USER_VERIFICATION)
    end

  end
  
  describe 'Event #search', :type => :request do
    before(:each) do
      @user1 = User.create(:email => 'email1@email.com', :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @user2 = User.create(:email => 'email2@email.com', :facebook_id => '668095230', :firstname => 'Red', :lastname => 'Pin')
      @user3 = User.create(email: 'andylee@gmail.com', facebook_id: 3, firstname: 'Andy', lastname: 'Lee')
      @user4 = User.create(email: 'ericcheong@gmail.com', facebook_id: 4, firstname: 'Eric', lastname: 'Cheong')
      @user5 = User.create(email: 'victorchang@gmail.com', facebook_id: 5, firstname: 'Victor', lastname: 'Chang')

      @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                             location: "2540 Regent St.", user_id: @user5.id, url: 'www.google.com', latitude: 37.86356, longitude: -122.25787, description: "It's Victor's birthday!")

      @event2 = Event.create(title: "Ben's Bash'", start_time: DateTime.new(2012,12,2), end_time: DateTime.new(2012,12,3),
                             location: "2530 Hillegass Ave.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86418, longitude: -122.25677, description: "Ben's birthday is coming up. Remember to bring presents!")

      @event3 = Event.create(title: "Eric's BBQ'", start_time: DateTime.new(2013,3,13), end_time: DateTime.new(2013,3,14),
                             location: "2520 College Ave.", user_id: @user4.id, url: 'www.google.com', latitude: 37.86483, longitude: -122.25420, description: "Meat, Steaks, Korean BBQ. No Vegatables needed. This is a man party.")

      @event4 = Event.create(title: "Andy's Picnic'", start_time: DateTime.new(2013,2,13), end_time: DateTime.new(2013,2,14),
                             location: "2200 Fulton St..", user_id: @user3.id, url: 'www.google.com', latitude: 37.86967, longitude: -122.26588, description: "Wine, cheese, sun, and good friends. Come everybody! It'll be a great day with great weather!")

      @event5 = Event.create(title: "Jerry's Lecture'", start_time: DateTime.new(2013,4,3), end_time: DateTime.new(2013,4,4),
                             location: "2300 Oxford St..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86872, longitude: -122.26628, description: "Jerry is teaching CS170. Come if you need help with algorithms")

      @event6 = Event.create(title: "Off The Grid", start_time: DateTime.new(2013,4,27), end_time: DateTime.new(2013,4,28),
                             location: "2450 Haste St..", user_id: @user1.id, url: 'www.google.com', latitude: 37.86595, longitude: -122.25908, description: "Great food! Though super expensive as fuck. I hope Korean Tacos are there!")

      @event7 = Event.create(title: "Hippie Celebration", start_time: DateTime.new(2013,4,30), end_time: DateTime.new(2013,5,1),
                             location: "2400 Bowditch Ave..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86720, longitude: -122.25654, description: "We are going to bake brownies. Bring other greens if you want.")

      @event8 = Event.create(title: "Holi Party", start_time: DateTime.new(2013,1,11), end_time: DateTime.new(2013,1,12),
                             location: "UC Berkeley.", user_id: @user3.id, url: 'www.google.com', latitude: 37.86948, longitude: -122.25969, description: "Holi Celebration at Berkeley! Buy your colors at the table this week!")

      @event9 = Event.create(title: "Danceworks Workshop", start_time: DateTime.new(2013,2,16), end_time: DateTime.new(2013,2,17),
                             location: "Lower Sproul", user_id: @user4.id, url: 'www.google.com', latitude: 37.86911, longitude: -122.26030, description: "We will be teaching Hip hop and Korean Pop right here on Sproul!")

      @event10 = Event.create(title: "Dead Poet's Society Meeting'", start_time: DateTime.new(2013,5,10), end_time: DateTime.new(2013,5,11),
                              location: "2100 Durant Ave.", user_id: @user5.id, url: 'www.google.com', latitude: 37.86669, longitude: -122.26759, description: "Read poetry. Speak poetry. Breathe poetry.")

      @event11 = Event.create(title: "Union Street's 22nd Annual Spring Celebration & Easter Parade", start_time: DateTime.new(2013,3,31), end_time: DateTime.new(2013,3,31),
                              location: "Union Street San Francisco, CA", user_id: @user1.id, url: 'www.google.com', latitude: 37.7985627, longitude: -122.4239345, description: "The 22nd annual event celebrates the diverse community of San Francisco and features some of Union Street's best restaurants in an outdoor bistro setting. A variety of children's and family activities are the focus of the event including; inflatable bouncies, kids' rides and games, a climbing wall, a petting zoo, a pony ride and entertainment from some of the Bay Area's best musicians. For the past 20 years the event has been known as the Biggest Little Parade in San Francisco.")

      @event12 = Event.create(title: "City Arts and Lectures presents Sheryl Sandberg In conversation with Condoleezza Rice", start_time: DateTime.new(2013,4,1), end_time: DateTime.new(2013,4,1),
                              location: "Nourse Theatre San Francisco, CA", user_id: @user2.id, url: 'www.google.com', latitude: 37.7749295, longitude: -122.4194155, description: "Sheryl Sandberg is Chief Operating Officer at Facebook. She oversees the firm's business operations including sales, marketing, business development, legal, human resources, public policy and communications. Prior to Facebook, Sheryl was vice president of Global Online Sales and Operations at Google, where she built and managed online sales for advertising and publishing and operations for consumer products worldwide. She was also instrumental in launching Google.org, Google's philanthropic arm.")

      @event13 = Event.create(title: "Treasure Island Flea Boutique Pop-Up Inside ~ Easter Show", start_time: DateTime.new(2013,3,30), end_time: DateTime.new(2013,3,30),
                              location: "Treasure Island Great Lawn San Francisco, CA", user_id: @user3.id, url: 'www.google.com', latitude: 37.7749295, longitude: -122.4194155, description: "Treasure Island Flea Boutique Easter Weekend Pop-Up Show.")

      @event14 = Event.create(title: "Amazing Urban Scavenger Hunt in San Francisco", start_time: DateTime.new(2013,3,28), end_time: DateTime.new(2013,3,28),
                              location: "Yerba Buena Park San Francisco, CA", user_id: @user4.id, url: 'www.google.com', latitude: 37.785094, longitude: -122.4027396, description: "Experience San Francisco in a whole new way on this scavenger hunt walking tour. Perfect for families, groups of friends and corporate team building activities.")

      @event15 = Event.create(title: "Youn Sun Nah'", start_time: DateTime.new(2013,6,23), end_time: DateTime.new(2013,6,23),
                              location: "Yoshi's San Francisco Live Music & Restaurant San Francisco, CA", user_id: @user5.id, url: 'www.google.com', latitude: 37.7749295, longitude: -122.4194155, description: "Youn Sun Nah is well regarded for her remarkable vocal prowess. The Korean jazz vocalist ability to present each song in her own unique style filled full of emotions and passion has consistently captured her audience in attentive silence, ending with roaring appreciation.")

      Sunspot.commit
    end

    after(:all) do
      Event.remove_all_from_index!
    end

    it 'returns SUCCESS and  a list of relevant events in Berkeley when we send in a search query and coordinates to search around' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Korean', location_query: 'Berkeley', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(3)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and a list of relevant events in San Francisco when we send in a search query and coordinates to search around' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Korean', location_query: 'San Francisco', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(1)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and an empty list if we search a query that does not have relevant events' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Chinese', location_query: 'San Francisco', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(0)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and an empty list if we search in a middle of no where location' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Korean', location_query: 'North Pole', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(0)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and all results for "Everything"' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Everything', location_query: 'Berkeley', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(10)
      parsed_body['next_page'].should be_nil
    end

    it 'returns ERR_BAD_LOCATION if we send a location query that does not make any sense' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Korean', location_query: 'Bad Location', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::ERR_BAD_LOCATION)
    end

    it 'should return ERR_NO_USER_EXISTS when a user searches but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { facebook_id: 'testUser3', session_token: @session_token, search_query: 'Korean', location_query: 'Berkeley', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_USER_EXISTS)
    end

    it 'should return ERR_USER_VERIFICATION when a user searches but the session token does not belong to the user' do
      params = { facebook_id: '100000450230611', session_token: 'FAKETOKEN', search_query: 'Korean', location_query: 'Berkeley', 'page' => 1}
      post '/events/search.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_USER_VERIFICATION)
    end

  end

  describe 'Event #searchViaCoordinates', :type => :request do
    before(:each) do
      @user1 = User.create(:email => 'email1@email.com', :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @user2 = User.create(:email => 'email2@email.com', :facebook_id => '668095230', :firstname => 'Red', :lastname => 'Pin')
      @user3 = User.create(email: 'andylee@gmail.com', facebook_id: 3, firstname: 'Andy', lastname: 'Lee')
      @user4 = User.create(email: 'ericcheong@gmail.com', facebook_id: 4, firstname: 'Eric', lastname: 'Cheong')
      @user5 = User.create(email: 'victorchang@gmail.com', facebook_id: 5, firstname: 'Victor', lastname: 'Chang')

      @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                             location: "2540 Regent St.", user_id: @user5.id, url: 'www.google.com', latitude: 37.86356, longitude: -122.25787, description: "It's Victor's birthday!")

      @event2 = Event.create(title: "Ben's Bash'", start_time: DateTime.new(2012,12,2), end_time: DateTime.new(2012,12,3),
                             location: "2530 Hillegass Ave.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86418, longitude: -122.25677, description: "Ben's birthday is coming up. Remember to bring presents!")

      @event3 = Event.create(title: "Eric's BBQ'", start_time: DateTime.new(2013,3,13), end_time: DateTime.new(2013,3,14),
                             location: "2520 College Ave.", user_id: @user4.id, url: 'www.google.com', latitude: 37.86483, longitude: -122.25420, description: "Meat, Steaks, Korean BBQ. No Vegatables needed. This is a man party.")

      @event4 = Event.create(title: "Andy's Picnic'", start_time: DateTime.new(2013,2,13), end_time: DateTime.new(2013,2,14),
                             location: "2200 Fulton St..", user_id: @user3.id, url: 'www.google.com', latitude: 37.86967, longitude: -122.26588, description: "Wine, cheese, sun, and good friends. Come everybody! It'll be a great day with great weather!")

      @event5 = Event.create(title: "Jerry's Lecture'", start_time: DateTime.new(2013,4,3), end_time: DateTime.new(2013,4,4),
                             location: "2300 Oxford St..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86872, longitude: -122.26628, description: "Jerry is teaching CS170. Come if you need help with algorithms")

      @event6 = Event.create(title: "Off The Grid", start_time: DateTime.new(2013,4,27), end_time: DateTime.new(2013,4,28),
                             location: "2450 Haste St..", user_id: @user1.id, url: 'www.google.com', latitude: 37.86595, longitude: -122.25908, description: "Great food! Though super expensive as fuck. I hope Korean Tacos are there!")

      @event7 = Event.create(title: "Hippie Celebration", start_time: DateTime.new(2013,4,30), end_time: DateTime.new(2013,5,1),
                             location: "2400 Bowditch Ave..", user_id: @user2.id, url: 'www.google.com', latitude: 37.86720, longitude: -122.25654, description: "We are going to bake brownies. Bring other greens if you want.")

      @event8 = Event.create(title: "Holi Party", start_time: DateTime.new(2013,1,11), end_time: DateTime.new(2013,1,12),
                             location: "UC Berkeley.", user_id: @user3.id, url: 'www.google.com', latitude: 37.86948, longitude: -122.25969, description: "Holi Celebration at Berkeley! Buy your colors at the table this week!")

      @event9 = Event.create(title: "Danceworks Workshop", start_time: DateTime.new(2013,2,16), end_time: DateTime.new(2013,2,17),
                             location: "Lower Sproul", user_id: @user4.id, url: 'www.google.com', latitude: 37.86911, longitude: -122.26030, description: "We will be teaching Hip hop and Korean Pop right here on Sproul!")

      @event10 = Event.create(title: "Dead Poet's Society Meeting'", start_time: DateTime.new(2013,5,10), end_time: DateTime.new(2013,5,11),
                              location: "2100 Durant Ave.", user_id: @user5.id, url: 'www.google.com', latitude: 37.86669, longitude: -122.26759, description: "Read poetry. Speak poetry. Breathe poetry.")

      @event11 = Event.create(title: "Union Street's 22nd Annual Spring Celebration & Easter Parade", start_time: DateTime.new(2013,3,31), end_time: DateTime.new(2013,3,31),
                              location: "Union Street San Francisco, CA", user_id: @user1.id, url: 'www.google.com', latitude: 37.7985627, longitude: -122.4239345, description: "The 22nd annual event celebrates the diverse community of San Francisco and features some of Union Street's best restaurants in an outdoor bistro setting. A variety of children's and family activities are the focus of the event including; inflatable bouncies, kids' rides and games, a climbing wall, a petting zoo, a pony ride and entertainment from some of the Bay Area's best musicians. For the past 20 years the event has been known as the Biggest Little Parade in San Francisco.")

      @event12 = Event.create(title: "City Arts and Lectures presents Sheryl Sandberg In conversation with Condoleezza Rice", start_time: DateTime.new(2013,4,1), end_time: DateTime.new(2013,4,1),
                              location: "Nourse Theatre San Francisco, CA", user_id: @user2.id, url: 'www.google.com', latitude: 37.7749295, longitude: -122.4194155, description: "Sheryl Sandberg is Chief Operating Officer at Facebook. She oversees the firm's business operations including sales, marketing, business development, legal, human resources, public policy and communications. Prior to Facebook, Sheryl was vice president of Global Online Sales and Operations at Google, where she built and managed online sales for advertising and publishing and operations for consumer products worldwide. She was also instrumental in launching Google.org, Google's philanthropic arm.")

      @event13 = Event.create(title: "Treasure Island Flea Boutique Pop-Up Inside ~ Easter Show", start_time: DateTime.new(2013,3,30), end_time: DateTime.new(2013,3,30),
                              location: "Treasure Island Great Lawn San Francisco, CA", user_id: @user3.id, url: 'www.google.com', latitude: 37.7749295, longitude: -122.4194155, description: "Treasure Island Flea Boutique Easter Weekend Pop-Up Show.")

      @event14 = Event.create(title: "Amazing Urban Scavenger Hunt in San Francisco", start_time: DateTime.new(2013,3,28), end_time: DateTime.new(2013,3,28),
                              location: "Yerba Buena Park San Francisco, CA", user_id: @user4.id, url: 'www.google.com', latitude: 37.785094, longitude: -122.4027396, description: "Experience San Francisco in a whole new way on this scavenger hunt walking tour. Perfect for families, groups of friends and corporate team building activities.")

      @event15 = Event.create(title: "Youn Sun Nah'", start_time: DateTime.new(2013,6,23), end_time: DateTime.new(2013,6,23),
                              location: "Yoshi's San Francisco Live Music & Restaurant San Francisco, CA", user_id: @user5.id, url: 'www.google.com', latitude: 37.7749295, longitude: -122.4194155, description: "Youn Sun Nah is well regarded for her remarkable vocal prowess. The Korean jazz vocalist ability to present each song in her own unique style filled full of emotions and passion has consistently captured her audience in attentive silence, ending with roaring appreciation.")

      Sunspot.commit
    end

    after(:all) do
      Event.remove_all_from_index!
    end

    it 'returns SUCCESS and  a list of relevant events in Berkeley when we send in a search query and coordinates to search around' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Korean', latitude: 37.8717, longitude: -122.2728, 'page' => 1}
      post '/events/searchViaCoordinates.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(3)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and a list of relevant events in San Francisco when we send in a search query and coordinates to search around' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Korean', latitude: 37.7749295, longitude: -122.4194155, 'page' => 1}
      post '/events/searchViaCoordinates.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(1)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and an empty list if we search a query that does not have relevant events' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Chinese', latitude: 37.7749295, longitude: -122.4194155, 'page' => 1}
      post '/events/searchViaCoordinates.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(0)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and an empty list if we search in a middle of no where location' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Korean', latitude: 90, longitude: 0, 'page' => 1}
      post '/events/searchViaCoordinates.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(0)
      parsed_body['next_page'].should be_nil
    end

    it 'returns SUCCESS and all results for "Everything"' do
      params = { facebook_id: '100000450230611', session_token: @session_token, search_query: 'Everything', latitude: 37.8717, longitude: -122.2728, 'page' => 1}
      post '/events/searchViaCoordinates.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body.should_not be_nil
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['events'].length.should equal(10)
      parsed_body['next_page'].should be_nil
    end

    it 'should return ERR_NO_USER_EXISTS when a user searches but user w/ facebook_id, {FACEBOOK_ID} does not exist in the database' do
      params = { facebook_id: 'testUser3', session_token: @session_token, search_query: 'Korean', latitude: 37.8717, longitude: -122.2728, 'page' => 1}
      post '/events/searchViaCoordinates.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_USER_EXISTS)
    end

    it 'should return ERR_USER_VERIFICATION when a user searches but the session token does not belong to the user' do
      params = { facebook_id: '100000450230611', session_token: 'FAKETOKEN', search_query: 'Korean', latitude: 37.8717, longitude: -122.2728, 'page' => 1}
      post '/events/searchViaCoordinates.json', params.to_json, { 'CONTENT_TYPE' => 'application/json'}
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_USER_VERIFICATION)
    end

  end

  describe 'Event #getPhotos', :type => :request do
    before(:each) do
      @user = User.create(:email => 'email@email.com', :facebook_id => '100000450230611', :firstname => 'Red', :lastname => 'Pin')
      @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
      @photo1 =  File.new('spec/fixtures/images/testEventImage.jpg', 'rb')
      @photo2 =  File.new('spec/fixtures/images/testEventImage2.jpg', 'rb')
      @event_image = EventImage.create!(:event_id => @event.id, :user_id => @user.id, :caption => 'Picture 1', :photo => @photo1)
      @event_image = EventImage.create!(:event_id => @event.id, :user_id => @user.id, :caption => 'Picture 2', :photo => @photo2)
    end

    it 'should return the urls of all photos associated to an event' do
      params = { event_id: @event.id }
      post '/events/getPhotos.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::SUCCESS)
      parsed_body['urls'].length.should equal(2)
    end


    it 'should return ERR_NO_EVENT_EXISTS if we ask for a list of photo urls of a event that does not exist in the database' do
      params = { event_id: 100 }
      post '/events/getPhotos.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should equal(RedPins::Application::ERR_NO_EVENT_EXISTS)
    end

  end

end
