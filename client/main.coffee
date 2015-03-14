Tracker.autorun ->
  if Meteor.user() and !Meteor.loggingIn()
    intercomSettings =
      name: Meteor.user().username
      email: Meteor.user().emails[0].address
      created_at: Math.round Meteor.user().createdAt/1000
      user_id: Meteor.user()._id
      favorite_color: _.sample ['blue', 'red', 'green', 'yellow']
      app_id: 'teitgkeh'
    Intercom 'boot', intercomSettings
