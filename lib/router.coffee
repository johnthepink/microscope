Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'
  waitOn: ->
    Meteor.subscribe 'notifications'

Router.route '/posts/:_id',
  name: 'postPage'
  waitOn: ->
    [
      Meteor.subscribe 'singlePost', @params._id
      Meteor.subscribe 'comments', @params._id
    ]
  data: -> Posts.findOne @params._id

Router.route '/posts/:_id/edit',
  name: 'postEdit'
  waitOn: ->
    Meteor.subscribe 'singlePost', @params._id
  data: -> Posts.findOne @params._id

Router.route '/submit', name: 'postSubmit'

@PostsListController = RouteController.extend
  template: 'postsList'
  increment: 5
  postsLimit: ->
    parseInt(@params.postsLimit) or @increment
  findOptions: ->
    {
      sort: @sort
      limit: @postsLimit()
    }
  subscriptions: ->
    @postsSub = Meteor.subscribe 'posts', @findOptions()
  waitOn: -> Meteor.subscribe 'posts', @findOptions()
  posts: -> Posts.find {}, @findOptions()
  data: ->
    hasMore = @posts().count() == @postsLimit()
    nextPath = @route.path(postsLimit: @postsLimit() + @increment)

    {
      posts: Posts.find({}, @findOptions())
      ready: @postsSub.ready
      nextPath: if hasMore then @nextPath() else null
    }

@NewPostsController = PostsListController.extend
  sort: submitted: -1, _id: -1
  nextPath: ->
    Router.routes.newPosts.path postsLimit: @postsLimit() + @increment

@BestPostsController = PostsListController.extend
  sort: votes: -1, submitted: -1, _id: -1
  nextPath: ->
    Router.routes.bestPosts.path postsLimit: @postsLimit() + @increment

Router.route '/',
  name: 'home'
  controller: NewPostsController

Router.route '/new/:postsLimit?', name: 'newPosts'
Router.route '/best/:postsLimit?', name: 'bestPosts'

Router.route '/feed.xml',
  where: 'server'
  name: 'rss'
  action: ->
    feed = new RSS
      title: "New Microscope Posts"
      description: "The latest posts from Mircoscope, the smallest news aggregator."
    Posts.find({}, sort: { submitted: -1 }, limit: 20).forEach (post) ->
      feed.item
        title: post.title
        description: post.body
        author: post.author
        date: post.submitted
        url: '/posts/' + post._id

    @response.write feed.xml()
    @response.end()

Router.route '/api/posts',
  where: 'server'
  name: 'apiPosts'
  action: ->
    parameters = @request.query
    limit = if parameters.limit then parseInt(parameters.limit) else 20
    data = Posts.find({}, limit: limit, fields: { title: 1, author: 1, url: 1, submitted: 1 } ).fetch()
    @response.write JSON.stringify(data)
    @response.end()

requireLogin = ->
  if ! Meteor.user()
    if Meteor.loggingIn()
      @render @loadingTemplate
    else
      @render 'accessDenied'
  else
    @next()

if Meteor.isClient
  Router.onBeforeAction 'dataNotFound', only: 'postPage'
  Router.onBeforeAction requireLogin, only: 'postSubmit'
