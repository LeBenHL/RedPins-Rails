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
  def search
    response = User.login(params['facebook_id'], params['session_token'])
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
        event_list.push(attributes)
      end
      @hash[:events] = event_list
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
