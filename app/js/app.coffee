## 1. Search stuff

captureFormSubmit = ($search, cb) ->
  $('form').on 'submit', ->
    $('[data-js-results-marker]').removeClass('results-ready')
    setTimeout ->
      cb($search, github: $('input').val())
    , 1750
    false

renderSearch = (github = githubQuery()) ->
  $search = render('search', {github})
  showAndHidePlaceholder()
  renderResults($search, {github})
  $search

githubQuery = ->
  new URI(window.location.href).search(true)['github'] || ""

render = (name, context, container = "[data-js-render-root]") ->
  $(container).html(JST["app/templates/#{name}"](context))

showAndHidePlaceholder = ->
  $input = $('[data-js-input]')
  ogPlaceholder = $input.attr('placeholder')
  $input.on 'focus', -> $input.attr('placeholder', '')
  $input.on 'blur', -> $input.attr('placeholder', ogPlaceholder)

handleResize = ->
  docHeight = $(window).height()
  containerHeight = $('[data-js-app-root]').outerHeight() + 190
  $('[data-js-app-root]').toggleClass('is-too-big', docHeight < containerHeight)

## 2. Results stuff

renderResults = ($search, context) ->
  return unless context.github
  render('results', context, $search.find('[data-js-results]'))
  $('[data-js-results-marker]').addClass('results-ready')


## 3. public static void main()
$ ->
  $search = renderSearch()
  captureFormSubmit($search, renderResults)
  handleResize()
  $(window).on('resize', handleResize)
