Accounts.onCreateUser (options, user) ->
  user.intercomHash = IntercomHash(user, Meteor.settings.intercom)

  if options.profile
    user.profile = options.profile

  user
