@Posts = new Mongo.Collection 'posts'

Posts.allow
  update: (userId, post) -> ownsDocument(userId, post)
  remove: (userId, post) -> ownsDocument(userId, post)

Posts.deny
  update: (userId, post, fieldNames, modifier) ->
    errors = validatePost modifier.$set
    return errors.title or errors.url

@validatePost = (post) ->
  errors = {}
  if !post.title
    errors.title = "Please fill in a headline"
  if !post.url
    errors.url = "Please fill in a URL"
  errors

Meteor.methods
  postInsert: (postAttributes) ->

    check Meteor.userId(), String

    check postAttributes,
      title: String,
      url: String

    errors = validatePost postAttributes
    if errors.title or errors.url
      throw new Meteor.error 'invalid-post', 'You must set a title and URL for your post'

    postWithSameLink = Posts.findOne url: postAttributes.url
    if postWithSameLink
      return {
        postExists: true,
        _id: postWithSameLink._id
      }

    user = Meteor.user()

    post = _.extend postAttributes,
      userId: user._id,
      author: user.username,
      submitted: new Date(),
      commentsCount: 0,
      upvoters: [],
      votes: 0

    postId = Posts.insert post

    return {
      _id: postId
    }

  upvote: (postId) ->
    check @userId, String
    check postId, String
    post = Posts.findOne postId
    if !post
      throw new Meteor.Error 'invalid', 'Post not found'
    if _.include(post.upvoters, @userId)
      throw new Meteor.Error 'invalid', 'Already upvoted this post'
    Posts.update post._id,
      $addToSet: upvoters: @userId
      $inc: votes: 1
