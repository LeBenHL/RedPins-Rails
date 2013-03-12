require 'spec_helper'

SUCCESS = 1
ERR_BAD_TITLE = -5
ERR_BAD_TIME = -6
ERR_BAD_LOCATION = -7

describe Event do
  it 'adds an event into the database with URL' do
    response = Event.add('test event1', DateTime.new(2013,4,1), "berkeley", "google.com")
    expect(response).to eq(SUCCESS)
  end
  
  it 'adds an event into the database without URL' do
    response = Event.add('test event2', DateTime.new(2013,3,9), "san jose, ca")
    expect(response).to eq(SUCCESS)
  end
end
