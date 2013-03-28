class EventsController < ApplicationController

  # POST /events/getRatings
  def getRatings
    begin
      @event = Event.find(params['event_id'])
      @hash = @event.getRatings
      @hash[:errCode] = RedPins::Application::SUCCESS
    rescue => ex
      @hash = {}
      @hash[:errCode] = RedPins::Application::ERR_NO_EVENT_EXISTS
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /events/add
  def add
    response = User.login(params['facebook_id'])
    @hash = {:errCode => response}
    if response > 0
      @event = Event.add(params['title'], params['start_time'], params['end_time'], params['location'], params['facebook_id'], params['url'], params['latitude'], params['longitude'])
      @hash[:errCode] = @event
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /events/getComments
  def getComments
    begin
      @event = Event.find(params['event_id'])
      @hash = {}
      @hash[:comments] = @event.getComments
      @hash[:errCode] = RedPins::Application::SUCCESS
    rescue => ex
      @hash = {}
      @hash[:errCode] = RedPins::Application::ERR_NO_EVENT_EXISTS
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /events/search
=begin
  def search
    response = User.login(params['facebook_id'], params['session_token'])
    @query = params['query']
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = RedPins::Application::SUCCESS
      @events = Event.find(:all, :limit => 10)
      event_list = []
      @events.each do |event|
        attributes = event.attributes
        if event.user_id == @user.id
          attributes[:owner] = true
        else
          attributes[:owner] = false
        end
        if event.title.include? @query
          event_list.push(attributes)
        end
      end
      @hash[:events] = event_list
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end
=end

  def search
    response = User.login(params['facebook_id'], params['session_token'])
    @query = params['query']
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = RedPins::Application::SUCCESS
      coords = Geocoder.coordinates(params['location_query'])
      @events = Event.searchEvents(params['search_query'], coords, @user.id, params['page'])
      @hash[:events] = @events
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /events/searchViaCoordinates
  def searchViaCoordinates
    response = User.login(params['facebook_id'], params['session_token'])
    @query = params['query']
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = RedPins::Application::SUCCESS
      coords = [params['latitude'], params['longitude']]
      @events = Event.searchEvents(params['search_query'], coords, @user.id, params['page'])
      @hash[:events] = @events
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /events/getEvent
  def getEvent
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      begin
        @event = Event.find(params['event_id'])
        @hash[:errCode] = RedPins::Application::SUCCESS
        attributes = @event.attributes
        if @event.user_id == @user.id
          attributes[:owner] = true
        else
          attributes[:owner] = false
        end
        @hash[:event] = attributes
      rescue
        @hash[:errCode] = RedPins::Application::ERR_NO_EVENT_EXISTS
      end
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

end
