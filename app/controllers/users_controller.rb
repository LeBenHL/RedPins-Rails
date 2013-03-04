class UsersController < ApplicationController

  # POST /users/login
  def login
    response = User.login(params['email'], params['facebook_id'])
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

end
