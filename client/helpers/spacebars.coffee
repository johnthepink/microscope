Template.registerHelper 'pluralize', (n, thing) ->
  # fairly stupid pluralizer
  n = 0 if n is undefined
  if n == 1
    '1 ' + thing
  else
    n + ' ' + thing + 's'
