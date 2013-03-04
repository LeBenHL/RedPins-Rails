require 'spec_helper'

describe UsersController do

  SUCCESS = 1
  ERR_NO_USER_EXISTS = -1
  ERR_USER_EXISTS = -2
  ERR_BAD_EMAIL = -3
  ERR_BAD_FACEBOOK_ID = -4

  describe 'Post #add', :type => :request do
    it 'creates a user object' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
    end

    it 'refuses to create users with duplicate emails' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      params2 = { email: 'email@email.com', facebook_id: 'testUser2' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/add.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_USER_EXISTS
    end

    it 'refuses to create users with duplicate facebook ids' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      params2 = { email: 'newEmail@email.com', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/add.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_USER_EXISTS
    end

    it 'refuses to create users with invalid email' do
      params = { email: 'fakeemail', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_BAD_EMAIL
    end
  end

  describe 'Post #login', :type => :request do
    it 'login when given valid account and email' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/login.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == SUCCESS
    end

    it 'refuse login to users with wrong facebook id' do
      params = { email: 'email@email.com', facebook_id: 'testUser' }
      params2 = { email: 'email@email.com', facebook_id: 'testUser2' }
      post '/users/add.json', params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/users/login.json', params2.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      parsed_body = JSON.parse(response.body)
      parsed_body['errCode'].should == ERR_NO_USER_EXISTS
    end

  end

end
