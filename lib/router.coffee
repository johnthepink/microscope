Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'
  waitOn: ->
    Meteor.subscribe 'notifications'

Router.route '/posts/:_id',
  name: 'postPage'
  waitOn: -> Meteor.subscribe 'comments', @.params._id
  data: -> Posts.findOne @.params._id

Router.route '/posts/:_id/edit',
  name: 'postEdit'
  data: -> Posts.findOne @.params._id

Router.route '/submit', name: 'postSubmit'

Router.route '/:postsLimit?',
  name: 'postsList'

  waitOn: ->
    limit = parseInt @.params.postsLimit or 5
    Meteor.subscribe 'posts', sort: { submitted: -1 }, limit: limit

  data: ->
    limit = parseInt @.params.postsLimit or 5
    posts: Posts.find {}, sort: { submitted: -1 }, limit

requireLogin = ->
  if ! Meteor.user()
    if Meteor.loggingIn()
      @.render @.loadingTemplate
    else
      @.render 'accessDenied'
  else
    @.next()

Router.onBeforeAction 'dataNotFound', only: 'postPage'
Router.onBeforeAction requireLogin, only: 'postSubmit'
