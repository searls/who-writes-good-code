## 1. Search stuff

LOADING_DELAY = 2000

generateReportCardFor = (github) ->
  unrenderResults()
  window.location.hash = "##{github}"
  $('[data-js-search-input]').val(github)
  $('[data-js-search-input]').blur()
  $('[data-js-loading-indicator]').addClass('is-loading')
  setTimeout ->
    renderResults($('[data-js-app-root]'), github)
    $('[data-js-loading-indicator]').removeClass('is-loading')
  , LOADING_DELAY
  false

renderSearch = (github = githubQuery()) ->
  render('search', {github})
  showAndHidePlaceholder()
  renderResults($('[data-js-app-root]'), github)

githubQuery = ->
  _(window.location.hash).rest().join("")

render = (name, context, container = "[data-js-render-root]") ->
  $(container).html(JST["app/templates/#{name}"](context))

showAndHidePlaceholder = ->
  $input = $('[data-js-input]')
  ogPlaceholder = $input.attr('placeholder')
  $input.on 'focus', ->
    $input.attr('placeholder', '')
    $('[data-js-input-border]').addClass('is-not-animating')
  $input.on 'blur', ->
    $input.attr('placeholder', ogPlaceholder)
    $('[data-js-input-border]').removeClass('is-not-animating')

handleResize = ->
  docHeight = $(window).height()
  resultsRendered = $('[data-js-app-root]').outerHeight() + 140
  $('[data-js-app-root]').toggleClass('is-too-big', resultsRendered > docHeight)

## 2. Results stuff

renderResults = ($search, github) ->
  return unless github
  $('[data-js-search-input]').blur()
  _(calculateResults(github)).tap (results) ->
    render('results', results, $search.find('[data-js-results]'))
    renderTwitterButton(github, results)
    $('[data-js-results-only]').removeClass('invisible').addClass('is-shown')
    $('[data-js-overall-grade-letter]').text(results.overall)
    $('[data-js-results-marker]').addClass('results-ready')
    setTimeout ->
      $('[data-js-percentage]').each (i, el) ->
        $(el).css(width: "#{results.grades[i].percentage}%")
        handleResize()
    , 400

renderTwitterButton = (github, results, container = '[data-js-twitter-button]') ->
  overallWithArticle = "#{aOrAn(results.overall)} #{results.overall}"
  render('twitter',
    title: "Tell the world you're #{overallWithArticle} developer!"
    tweet: "A website said I was #{overallWithArticle} developer when I gave it my GitHub username! How good a developer are you?"
  , container)
  $.ajax(url: 'http://platform.twitter.com/widgets.js', dataType: 'script', cache:true) #lmao if your API doesn't support renders after domready


aOrAn = (overall) ->
  if _(['A', 'F']).include(_(overall).first()) then "an" else "a"

unrenderResults = ->
  $('[data-js-results-only]').addClass('invisible')
  $('[data-js-results-marker]').removeClass('results-ready')
  $('[data-js-results-only]').addClass('invisible').removeClass('is-shown')
  $('[data-js-overall-grade-letter]').text('')

calculateResults = (github) ->
  grades = calculateGrades(github)
  overall = averageLetterGrade(grades)
  {grades, overall}

averageLetterGrade = (grades) ->
  letterGradeFromPercentage(
    _(grades).reduce((memo, grade) ->
      memo + grade.percentage
    , 0) / grades.length
  )

localStorageify = (cb) ->
  (key) ->
    return JSON.parse(localStorage[key]) if localStorage[key]?
    _(cb(key)).tap (value) -> localStorage[key] = JSON.stringify(value)

calculateGrades = localStorageify (github) ->
  _(pickCriteria()).map (name) ->
    name: name
    percentage: percentage = randomPercentage(randomWeightingsFor(github))
    letter: letterGradeFromPercentage(percentage)

CODE_QUALITIES = [
  "Thoughtfulness of Names"
  "Expressiveness of Tests"
  "Empathy for Maintainers"
  "Future-proof Avoidance"
  "Conscientious Logging"
  "Commit Message Clarity"
  "Dependency Restraint"
  "Release Strategy"
  "Coherent Versioning"
  "Convention Adherance"
  "Pairing — Navigation"
  "Pairing — Driving"
  "Expectation Management"
  "Googling for Answers"
  "Respectful of Others"
]

pickCriteria = ->
  _(CODE_QUALITIES).chain().shuffle().first(5).value()

# How this works:
# The randomPercentage function takes an array of minimum values relative to
#   a max of 100(%). So if you return [0, 50], then two random values will be
#   calculated, one from 0-100 and one from 50-100, then of those two, one will
#   be randomly chosen. That means you'd be twice as likely to draw a 75 than a
#   25. This is useful b/c truly random 0-100 grades don't look like normal grades
#   at all thanks to the perceived floor of 30-45% and typical grade inflation.
#   Users would feel like the tool was unrealistic if it spat out D- averages for
#   most people.
#
#  Oh and don't mind the thing about A+ students. Nothing to see here.
randomWeightingsFor = (github) ->
  if _(A_PLUS_STUDENTS).include(github)
    [96, 98]
  else
    [0,40,60,70,80,85,90]

randomPercentage = (weightings = [0]) ->
  _(weightings).chain().map (n) ->
    _.random(n, 100)
  .sample().value()

LETTER_GRADES =
  59: "F"
  63: "D-"
  66: "D"
  69: "D+"
  73: "C-"
  76: "C"
  79: "C+"
  83: "B-"
  86: "B"
  89: "B+"
  93: "A-"
  96: "A"
  100: "A+"

A_PLUS_STUDENTS = [
  "pixeljanitor"
  "bkeepers"
  "tkaufman"
  "searls"
  "jasonkarns"
  "andrewvida"
  "theotherzach"
  "bostonaholic"
  "davemo"
  "neall"
  "kbaribeau"
  "danthompson"
  "crebma"
  "dustintinney"
]


letterGradeFromPercentage = (percentage) ->
  _(LETTER_GRADES).find (grade, cutoff) ->
    percentage <= parseInt(cutoff, 10)

## 3. public static void main()
$ ->
  renderSearch()
  handleResize()
  $('form').on('submit', -> generateReportCardFor($('[data-js-search-input]').val()))
  $('[data-js-new-entry]').on('click', -> unrenderResults())
  $(window).on('hashchange', -> generateReportCardFor(githubQuery()))
  $(window).on('resize', handleResize)
