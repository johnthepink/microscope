Tracker.autorun ->
  if Meteor.user() and !Meteor.loggingIn()
    intercomSettings =
      name: Meteor.user().username
      email: Meteor.user().emails[0].address
      created_at: Math.round Meteor.user().createdAt/1000
      favorite_color: _.sample ['blue', 'red', 'green', 'yellow']
      user_id: Meteor.user()._id
      user_hash: Meteor.user().intercomHash
      widget:
        activator: '#Intercom'
        user_counter: true
      app_id: 'teitgkeh'
    Intercom 'boot', intercomSettings
