require 'spec_helper'

SUCCESS = 1
ERR_NO_USER_EXISTS = -1
ERR_USER_EXISTS = -2
ERR_BAD_EMAIL = -3
ERR_BAD_FACEBOOK_ID = -4

describe User do
  it 'adds a user into the database' do
    response = User.add('email@email.com', 'testUser')
    expect(response).to eq(SUCCESS)
  end

  it 'refuses to add a user with duplicate email' do
    User.add('email@email.com', 'testUser')
    response = User.add('email@email.com', 'anotherTestUser')
    expect(response).to eq(ERR_USER_EXISTS)
  end

  it 'refuses to add a user with a duplicate facebook id' do
    User.add('email@email.com', 'testUser')
    response = User.add('newEmail@email.com', 'testUser')
    expect(response).to eq(ERR_USER_EXISTS)
  end

  it 'refuses to add a user with an invalid email' do
    response = User.add('fakeEmail', 'testUser')
    expect(response).to eq(ERR_BAD_EMAIL)
  end

  it 'returns SUCCESS when user logins with a proper facebook id' do
    User.add('email@email.com', 'testUser')
    response = User.login('email@email.com', 'testUser')
    expect(response).to eq(SUCCESS)
  end

  it 'fails when user logins with a facebook id not recognized in the DB' do
    User.add('email@email.com', 'testUser')
    response = User.login('email@email.com', 'anotherTestUser')
    expect(response).to eq(ERR_NO_USER_EXISTS)
  end
end
