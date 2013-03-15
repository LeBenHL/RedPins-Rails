class SearchController < ApplicationController
  #GET /events
  #GET /events.json
  
  # POST /events/search
  def search
    @events = Event.find(:title == )
    @hash = {}
    
    event_list = []
    @events.each do |event|
      event_list.push(event.attributes)
    end
    @hash[:events] = event_list
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end
    
