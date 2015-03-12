Template.postSubmit.events
  'submit form': (e) ->
    e.preventDefault()

    post =
      url: $(e.target).find('[name=url]').val(),
      title: $(e.target).find('[name=title]').val()

    Meteor.call 'postInsert', post, (error, result) ->
      # display the error to the user and abort
      if error
        alert error.reason
      Router.go 'postPage', _id: result._id
