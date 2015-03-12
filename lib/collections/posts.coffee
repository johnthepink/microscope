@Posts = new Mongo.Collection 'posts'

Meteor.methods
  postInsert: (postAttributes) ->

    check Meteor.userId(), String

    check postAttributes,
      title: String,
      url: String

    user = Meteor.user()

    post = _.extend postAttributes,
      userId: user._id,
      author: user.username,
      submitted: new Date()

    postId = Posts.insert post

    return {
      _id: postId
    }
