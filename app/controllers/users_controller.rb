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

  # POST /users/likeEvent
  def likeEvent
    response = User.login(params['facebook_id'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      response = @user.likeEvent(params['event_id'], params['like'])
      if response
        @hash[:errCode] = RedPins::Application::SUCCESS
      else
        @hash[:errCode] = RedPins::Application::ERR_USER_LIKE_EVENT
      end
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/removeLike
  def removeLike
    response = User.login(params['facebook_id'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      response = @user.removeLike(params['event_id'])
      if response
        @hash[:errCode] = RedPins::Application::SUCCESS
      else
        @hash[:errCode] = RedPins::Application::ERR_USER_LIKE_EVENT
      end
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/alreadyLikedEvent
  def likeEvent?
    response = User.login(params['facebook_id'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = RedPins::Application::SUCCESS
      response = @user.likeEvent?(params['event_id'])
      @hash[:alreadyLikedEvent] = response
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

end
