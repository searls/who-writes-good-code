## 1. Search stuff

captureFormSubmit = ($search, cb) ->
  $('form').on 'submit', ->
    cb($search, github: $('input').val())
    false

renderSearch = (github = githubQuery()) ->
  $search = render('search', {github})
  showAndHidePlaceholder()
  renderResults($search, {github})
  $search

githubQuery = ->
  new URI(window.location.href).search(true)['github'] || ""

render = (name, context, container = ".app") ->
  $(container).html(JST["app/templates/#{name}"](context))

showAndHidePlaceholder = ->
  $input = $('[data-js-input]')
  ogPlaceholder = $input.attr('placeholder')
  $input.on 'focus', -> $input.attr('placeholder', '')
  $input.on 'blur', -> $input.attr('placeholder', ogPlaceholder)

handleResize = ->
  docHeight = $(window).height()
  containerHeight = $('.container').outerHeight() + 190
  $('.container').toggleClass('is-too-big', docHeight < containerHeight)

## 2. Results stuff

renderResults = ($search, context) ->
  return unless context.github
  render('results', context, $search.find('[data-js-results]'))
  $('.input-content').addClass('results-ready')


## 3. public static void main()
$ ->
  $search = renderSearch()
  captureFormSubmit($search, renderResults)
  handleResize()
  $(window).on('resize', handleResize)
