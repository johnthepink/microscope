Meteor.publish 'posts', ->
  return Posts.find()

Meteor.publish 'comments', (postId) ->
  check postId, String
  return Comments.find postId: postId

Meteor.publish 'notifications', ->
  Notifications.find()
