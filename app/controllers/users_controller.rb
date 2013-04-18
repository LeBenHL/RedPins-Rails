class UsersController < ApplicationController

  # POST /users/login
  def login
    response = User.login(params['facebook_id'], params['session_token'])
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
    response = User.verify(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @hash[:errCode] = User.add(params['email'], params['facebook_id'], params['firstname'], params['lastname'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/likeEvent
  def likeEvent
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.likeEvent(params['event_id'], params['like'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/removeLike
  def removeLike
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.removeLike(params['event_id'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/alreadyLikedEvent
  def likeEvent?
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @event = Event.find(params['event_id'])
      @hash = @event.getRatings
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = RedPins::Application::SUCCESS
      likeResponse = @user.likeEvent?(params['event_id'])
      @hash[:alreadyLikedEvent] = likeResponse[:alreadyLikedEvent]
      if likeResponse[:alreadyLikedEvent]
        @hash[:rating] = likeResponse[:like]
      end
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/postComment
  def postComment
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.postComment(params['event_id'], params['comment'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/removeComment
  def removeComment
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.removeComment(params['comment_id'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/bookmarkEvent
  def bookmarkEvent
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.bookmarkEvent(params['event_id'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/removeBookmark
  def removeBookmark
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.removeBookmark(params['event_id'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/deleteEvent
  def deleteEvent
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.deleteEvent(params['event_id'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/cancelEvent
  def cancelEvent
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.cancelEvent(params['event_id'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/restoreEvent
  def restoreEvent
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash[:errCode] = @user.restoreEvent(params['event_id'])
    else
      @hash[:errCode] = response
    end
    respond_to do |format|
      format.json { render :json => @hash }
    end
  end

  # POST /users/uploadPhoto
  def uploadPhoto
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash = @user.uploadPhoto(params['event_id'], params['photo'])
    else
      @hash[:errCode] = response
    end
    render :json => @hash
  end

  # POST /users/getBookmarks
  def getBookmarks
    response = User.login(params['facebook_id'], params['session_token'])
    @hash = {}
    if response > 0
      @user = User.getUser(params['facebook_id'])
      @hash = @user.getBookmarks(params['page'])
    else
      @hash[:errCode] = response
    end
    render :json => @hash
  end

end
