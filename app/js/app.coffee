$ ->
  $search = renderSearch()
  captureFormSubmit($search, renderResults)


captureFormSubmit = ($search, cb) ->
  $('form').on 'submit', ->
    cb($search, github: $('input').val())
    false

renderSearch = (github = githubQuery()) ->
  $search = render('search', {github})
  showAndHidePlaceholder()
  renderResults($search, {github})
  $search

renderResults = ($search, context) ->
  return unless context.github
  render('results', context, $search.find('[data-js-results]'))
  $('[data-js-results]').addClass('visible')

render = (name, context, container = ".app") ->
  $(JST["app/templates/#{name}"](context)).appendTo($(container))

githubQuery = ->
  new URI(window.location.href).search(true)['github'] || ""

showAndHidePlaceholder = ->
  $input = $('[data-js-input]')
  ogPlaceholder = $input.attr('placeholder')

  $input.on 'focus', -> $input.attr('placeholder', '')
  $input.on 'blur', -> $input.attr('placeholder', ogPlaceholder)
