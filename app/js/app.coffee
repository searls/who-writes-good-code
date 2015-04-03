$ ->
  github = githubQuery()
  render('search', {github})
  render('results', {github}) if github

render = (name, context) ->
  $(JST["app/templates/#{name}"](context)).appendTo(".app")

githubQuery = ->
  new URI(window.location.href).search(true)['github']
