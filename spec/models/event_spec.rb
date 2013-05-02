# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :text
#  url         :string(255)
#  location    :string(255)
#  start_time  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  end_time    :datetime
#  user_id     :integer
#  canceled    :boolean          default(FALSE), not null
#  latitude    :float
#  longitude   :float
#  description :text
#

require 'spec_helper'

describe Event do

  before(:each) do
    @user = User.create(:email => 'email@email.com', :facebook_id => 'testUser', :firstname => 'Red', :lastname => 'Pin')
    @event = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :location => 'Berkeley', :url => 'www.thEvent.com', :user_id => @user.id)
    @user.should_not be_nil
    @event.should_not be_nil
  end

  after(:all) do
    Event.remove_all_from_index!
  end

  it 'adds an event into the database with URL' do
    response = Event.add('test event1', DateTime.new(2013,4,1), DateTime.new(2013,4,4),"Berkeley", @user.facebook_id, "google.com")
    expect(response[:errCode]).to eq(RedPins::Application::SUCCESS)
  end
  
  it 'adds an event into the database without URL' do
    response = Event.add('test event2', DateTime.new(2013,3,9), DateTime.new(2015,1,9), "Berkeley",  @user.facebook_id)
    expect(response[:errCode]).to eq(RedPins::Application::SUCCESS)
  end
  
  it 'adds an event with the same start date and end date' do
    response = Event.add('testevent3', DateTime.new(2013,1,2), DateTime.new(2013,1,2), "Berkeley", @user.facebook_id)
    response[:errCode].should equal(RedPins::Application::SUCCESS)
  end
  
  it 'refuses to add an event without a location' do
    response = Event.add('testevent4', DateTime.new(2013,1,2), DateTime.new(2013,1,2), "", @user.facebook_id)
    response[:errCode].should equal(RedPins::Application::ERR_BAD_LOCATION)
  end
  
  it 'refuses to add an event without a title' do
    response = Event.add('', DateTime.new(2013,1,9), DateTime.new(2013,1,9), "Berkeley", @user.facebook_id)
    response[:errCode].should equal(RedPins::Application::ERR_BAD_TITLE)
  end
  
  it 'refuses to add an event without a start time' do
    response = Event.add('OTG', "", DateTime.new(2013,1,9), "Berkeley", @user.facebook_id)
    response[:errCode].should equal(RedPins::Application::ERR_BAD_START_TIME)
  end
  
  it 'refuses to add an event ending before it starts' do
    response = Event.add('OTG', DateTime.new(2013,4,10), DateTime.new(2013,4,4), "Berkeley", @user.facebook_id)
    response[:errCode].should equal(RedPins::Application::ERR_EVENT_CREATION)
  end

  it 'refuses to add an event without an end time' do
    response = Event.add('OTG', DateTime.new(2013,4,10), "", "Berkeley", @user.facebook_id)
    response[:errCode].should equal(RedPins::Application::ERR_BAD_END_TIME)
  end

  it 'geocodes the event when it is added' do
    @event.latitude.should eq(37.8717)
    @event.longitude.should eq(-122.2728)
  end

  it 'reverse geocodes the event when it is added' do
    @event2 = Event.create(:title => 'newEvent', :start_time => '2013-03-14', :end_time => '2013-03-15', :latitude => 37.8717, :longitude => -122.2728, :url => 'www.thEvent.com', :user_id => @user.id)
    @event2.location.should eq('Berkeley, CA, USA')
  end

  it 'knows how many likes and dislikes it has' do
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
    ratings = @event.getRatings
    ratings[:likes].should equal(3)
    ratings[:dislikes].should equal(2)
  end

  it 'returns all comments associated with it' do
    @user1 = User.create(:email => 'email1@email.com', :facebook_id => 'testUser1', :firstname => 'Red', :lastname => 'Pin')
    @user2 = User.create(:email => 'email2@email.com', :facebook_id => 'testUser2', :firstname => 'Red', :lastname => 'Pin')
    @user3 = User.create(:email => 'email3@email.com', :facebook_id => 'testUser3', :firstname => 'Red', :lastname => 'Pin')
    @user1.postComment(@event.id, 'I LOVE THIS EVENT')
    @user1.postComment(@event.id, 'I HATE THIS EVENT')
    @user2.postComment(@event.id, 'WOW SO BIPOLAR')
    @user2.postComment(@event.id, 'REDPIN USERS HIGH INTELLIGENCE')
    @user3.postComment(@event.id, 'WOW GUYS JUST LEAVE PLEASE BEFORE BAN')
    @event.reload
    commentsArray = @event.getComments
    commentsArray.length.should equal(5)
  end

  describe 'testing SOLR searches' do

    before(:each) do
      @user1 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @user2 = User.create(email: 'jerrychen@gmail.com', facebook_id: 2, firstname: 'Jerry', lastname: 'Chen')
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

    it 'returns a list of relevant events in Berkeley when we send in a search query and coordinates to search around' do
      sleep 2
      search = Event.searchEvents('Korean', Geocoder.coordinates('Berkeley'), @user1.id)
      event3 = @event3.attributes
      event3[:owner] = false
      event3[:isPhoto] = false
      event3[:likes] = 0
      event3[:dislikes] = 0
      search[:events].should include(event3)
      event6 = @event6.attributes
      event6[:owner] = true
      event6[:isPhoto] = false
      event6[:likes] = 0
      event6[:dislikes] = 0
      search[:events].should include(event6)
      event9 = @event9.attributes
      event9[:owner] = false
      event9[:isPhoto] = false
      event9[:likes] = 0
      event9[:dislikes] = 0
      search[:events].should include(event9)
      event15 = @event15.attributes
      event15[:owner] = false
      event15[:isPhoto] = false
      event15[:likes] = 0
      event15[:dislikes] = 0
      search[:events].should_not include(event15)
      search[:next_page].should be_nil
    end

    it 'returns a list of relevant events in SF when we send in a search query and coordinates to search around' do
      sleep 2
      search = Event.searchEvents('Korean', Geocoder.coordinates('San Francisco'), @user1.id)
      event3 = @event3.attributes
      event3[:owner] = false
      event3[:isPhoto] = false
      event3[:likes] = 0
      event3[:dislikes] = 0
      search[:events].should_not include(event3)
      event6 = @event6.attributes
      event6[:owner] = true
      event6[:isPhoto] = false
      event6[:likes] = 0
      event6[:dislikes] = 0
      search[:events].should_not include(event6)
      event9 = @event9.attributes
      event9[:owner] = false
      event9[:isPhoto] = false
      event9[:likes] = 0
      event9[:dislikes] = 0
      search.should_not include(event9)
      event15 = @event15.attributes
      event15[:owner] = false
      event15[:isPhoto] = false
      event15[:likes] = 0
      event15[:dislikes] = 0
      search[:events].should include(event15)
      search[:next_page].should be_nil
    end

    it 'returns an empty list if we search a query that does not have relevant events' do
      sleep 2
      search = Event.searchEvents('Chinese', Geocoder.coordinates('Berkeley'), @user1.id)
      search[:events].should be_empty
      search[:next_page].should be_nil
    end


    it 'returns an empty list if we search in a middle of no where location' do
      sleep 2
      search = Event.searchEvents('Korean', Geocoder.coordinates('North Pole'), @user1.id)
      search[:events].should be_empty
      search[:next_page].should be_nil
    end

    it 'returns all events if we ask for "Everything"' do
      sleep 2
      search = Event.searchEvents('Everything', Geocoder.coordinates('Berkeley'), @user1.id)
      search[:events].count.should eq(10)
      search[:next_page].should_not be_nil
    end
  end

  describe 'testing getPhotos' do
    before(:each) do
      @user1 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
      @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                             location: "2540 Regent St.", user_id: @user1.id, url: 'www.google.com', latitude: 37.86356, longitude: -122.25787, description: "It's Victor's birthday!")
      @photo1 =  File.new('spec/fixtures/images/testEventImage.jpg', 'rb')
      @photo2 =  File.new('spec/fixtures/images/testEventImage2.jpg', 'rb')
      @event_image = EventImage.create!(:event_id => @event1.id, :user_id => @user1.id, :caption => 'Picture 1', :photo => @photo1)
      @event_image = EventImage.create!(:event_id => @event1.id, :user_id => @user1.id, :caption => 'Picture 2', :photo => @photo2)
    end

    after(:all) do
      Event.remove_all_from_index!
    end

    it 'should return an array of image URLs when call getPhotos for an event' do
      photos = @event1.getPhotos
      photos[:errCode].should eq(RedPins::Application::SUCCESS)
      photos[:urls].length.should eq(2)
    end

  end

end
