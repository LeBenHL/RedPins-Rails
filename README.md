RedPins-Rails
=============

To run tests on Rails app, first run **rake db:test:load** to prepare the database and **rake sunspot:solr:start RAILS_ENV=test** to to start the local solr server. Then run **rspec** to run the tests. 1 test should fail but this has not been fixed yet because I am having trouble stubbing a Geocoder location.

To run the rails app. First run **rake db:migrate** to create the database. Then run **rake db:seed** to seed the database with some data. Then run **rake sunspot:solr:start** to start the local solr server. Run **rails s -p [port number]** to start a local server on localhost:[port_number].
