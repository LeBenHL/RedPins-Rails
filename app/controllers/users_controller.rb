class UsersController < ApplicationController

  # POST /users/login
  def login
    response = User.login(params['facebook_id'])
    @hash = {}
    if response > 0
      @hash[:errCode] = response
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
     format.json { render :json => @hash }
    end
  end

  # POST /users/add
  def add
    response = User.add(params['email'], params['facebook_id'])
    @hash = {}
    if response > 0
      @hash[:errCode] = response
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/rateEvent
  def rateEvent
  end

  # POST /users/deleteRating
  def deleteRatingForEvent

  end

  # POST /users/alreadyRatedEvent
  def rateEvent?

  end

end
