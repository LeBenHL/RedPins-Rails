# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
    @user1 = User.create(email: 'benle@gmail.com', facebook_id: 1, firstname: 'Ben', lastname: 'Le')
    @user2 = User.create(email: 'jerrychen@gmail.com', facebook_id: 2, firstname: 'Jerry', lastname: 'Chen')
    @user3 = User.create(email: 'andylee@gmail.com', facebook_id: 3, firstname: 'Andy', lastname: 'Lee')
    @user4 = User.create(email: 'ericcheong@gmail.com', facebook_id: 4, firstname: 'Eric', lastname: 'Cheong')
    @user5 = User.create(email: 'victorchang@gmail.com', facebook_id: 5, firstname: 'Victor', lastname: 'Chang')

    @event1 = Event.create(title: "Victor's Party", start_time: DateTime.new(2010,9,8), end_time: DateTime.new(2010,9,10),
                          location: "2540 Regent St.", user_id: @user5.id, url: 'www.google.com', latitude: 36, longitude: -122)

    @event2 = Event.create(title: "Ben's Bash'", start_time: DateTime.new(2012,12,2), end_time: DateTime.new(2012,12,3),
                           location: "2530 Hillegass Ave.", user_id: @user1.id, url: 'www.google.com', latitude: 36.01, longitude: -122.01)

    @event3 = Event.create(title: "Eric's BBQ'", start_time: DateTime.new(2013,3,13), end_time: DateTime.new(2013,3,14),
                           location: "2520 College Ave.", user_id: @user4.id, url: 'www.google.com', latitude: 36.02, longitude: -122.02)

    @event4 = Event.create(title: "Andy's Picnic'", start_time: DateTime.new(2013,2,13), end_time: DateTime.new(2013,2,14),
                           location: "2200 Fulton St..", user_id: @user3.id, url: 'www.google.com', latitude: 36.03, longitude: -122.03)

    @event5 = Event.create(title: "Jerry's Lecture'", start_time: DateTime.new(2013,4,3), end_time: DateTime.new(2013,4,4),
                           location: "2300 Oxford St..", user_id: @user2.id, url: 'www.google.com', latitude: 36.04, longitude: -122.04)

    @event6 = Event.create(title: "Off The Grid", start_time: DateTime.new(2013,4,27), end_time: DateTime.new(2013,4,28),
                           location: "2450 Haste St..", user_id: @user1.id, url: 'www.google.com', latitude: 36.05, longitude: -122.05)

    @event7 = Event.create(title: "Hippie Celebration", start_time: DateTime.new(2013,4,30), end_time: DateTime.new(2013,5,1),
                           location: "2400 Bowditch Ave..", user_id: @user2.id, url: 'www.google.com', latitude: 36.01, longitude: -121.99)

    @event8 = Event.create(title: "Holi Party", start_time: DateTime.new(2013,1,11), end_time: DateTime.new(2013,1,12),
                           location: "UC Berkeley.", user_id: @user3.id, url: 'www.google.com', latitude: 36.02, longitude: -121.98)

    @event9 = Event.create(title: "Danceworks Workshop", start_time: DateTime.new(2013,2,16), end_time: DateTime.new(2013,2,17),
                           location: "Lower Sproul", user_id: @user4.id, url: 'www.google.com', latitude: 36.03, longitude: -121.97)

    @event10 = Event.create(title: "Dead Poet's Society Meeting'", start_time: DateTime.new(2013,5,10), end_time: DateTime.new(2013,5,11),
                           location: "2100 Durant Ave.", user_id: @user5.id, url: 'www.google.com', latitude: 36.04, longitude: -121.96)

    @user1.likeEvent(@event1.id, true)
    @user1.likeEvent(@event2.id, true)
    @user1.likeEvent(@event3.id, false)
    @user1.likeEvent(@event4.id, false)
    @user1.likeEvent(@event7.id, false)

    @user2.likeEvent(@event1.id, true)
    @user2.likeEvent(@event4.id, false)
    @user2.likeEvent(@event6.id, true)
    @user2.likeEvent(@event7.id, true)
    @user2.likeEvent(@event10.id, false)

    @user3.likeEvent(@event1.id, true)
    @user3.likeEvent(@event3.id, true)
    @user3.likeEvent(@event4.id, false)
    @user3.likeEvent(@event6.id, true)
    @user3.likeEvent(@event9.id, true)

    @user4.likeEvent(@event1.id, false)
    @user4.likeEvent(@event4.id, false)
    @user4.likeEvent(@event5.id, false)
    @user4.likeEvent(@event7.id, false)
    @user4.likeEvent(@event9.id, false)

    @user5.likeEvent(@event2.id, true)
    @user5.likeEvent(@event4.id, true)
    @user5.likeEvent(@event6.id, true)
    @user5.likeEvent(@event8.id, true)
    @user5.likeEvent(@event10.id, true)

    @user1.bookmarkEvent(@event2.id)
    @user1.bookmarkEvent(@event6.id)

    @user2.bookmarkEvent(@event5.id)
    @user2.bookmarkEvent(@event7.id)

    @user3.bookmarkEvent(@event4.id)
    @user3.bookmarkEvent(@event8.id)

    @user4.bookmarkEvent(@event3.id)
    @user4.bookmarkEvent(@event9.id)

    @user5.bookmarkEvent(@event1.id)
    @user5.bookmarkEvent(@event10.id)

    @user1.postComment(@event1.id, 'I LOVE BIRTHDAY CAKE')
    @user1.postComment(@event2.id, 'PLEASE BRING FOOD')
    @user1.postComment(@event3.id, 'THERE IS NO PARKING ANYWHERE HERE. YOU NEED TO WAIT 15 MINUTES BEFORE A SPOT OPENS UP')
    @user1.postComment(@event4.id, 'FOOD IS TERRIBLE')
    @user1.postComment(@event7.id, 'EATING SANDWHICHES GOOD.')

    @user2.postComment(@event1.id, 'HAPPY BIRTHDAY VICTOR')
    @user2.postComment(@event4.id, 'WHERE IS THIS GOING TO BE AGAIN')
    @user2.postComment(@event6.id, 'EXPENSIVE FOOD')
    @user2.postComment(@event7.id, 'I LOVE TO HOTBOX')
    @user2.postComment(@event10.id, 'SO DA HIPSTER')

    @user3.postComment(@event1.id, 'WHEN IS THE SURPRISE PARTY?')
    @user3.postComment(@event3.id, 'BURGERS OR HOTDOGS')
    @user3.postComment(@event4.id, 'IS THIS A POTLUCK?')
    @user3.postComment(@event6.id, 'THIS FOOD SO DA EXPENSIVE')
    @user3.postComment(@event9.id, 'DANCE DANCE DANCE DANCE EVERYBODY')

    @user4.postComment(@event1.id, 'WOW VICTOR CAN SEE THIS BRO')
    @user4.postComment(@event4.id, 'YAY EVERYONE IS GOING TO ANDYS THING')
    @user4.postComment(@event5.id, 'WHAT ARE YOU LECTURING ABOUT')
    @user4.postComment(@event7.id, 'WHAT THE HECK IS THIS EVENT')
    @user4.postComment(@event9.id, 'SHOW ME YOUR MOVES')

    @user5.postComment(@event2.id, 'I LOVE YOU BEN')
    @user5.postComment(@event4.id, 'I HATE YOU ANDY')
    @user5.postComment(@event6.id, 'I LOVE TRUCK FOOD')
    @user5.postComment(@event8.id, 'I LOVE COLORS')
    @user5.postComment(@event10.id, 'I LOVE ROBIN WILLIAMS')







