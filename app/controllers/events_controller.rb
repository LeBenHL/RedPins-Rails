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

end
