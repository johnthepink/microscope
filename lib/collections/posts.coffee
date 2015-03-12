@Posts = new Mongo.Collection 'posts'

Posts.allow
  insert: (userId, doc) ->
    # only allow posting if you are logged in
    return !! userId
