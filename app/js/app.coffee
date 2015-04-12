## 1. Search stuff

LOADING_DELAY = 1000

generateReportCardFor = (github) ->
  unrenderResults()
  window.location.hash = "##{github}"
  $('[data-js-search-input]').val(github)
  setTimeout ->
    renderResults($('[data-js-app-root]'), github)
  , LOADING_DELAY + 750
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
  $input.on 'focus', -> $input.attr('placeholder', '')
  $input.on 'blur', -> $input.attr('placeholder', ogPlaceholder)

handleResize = ->
  docHeight = $(window).height()
  containerHeight = $('[data-js-app-root]').outerHeight() + 190
  $('[data-js-app-root]').toggleClass('is-too-big', docHeight < containerHeight)

## 2. Results stuff

renderResults = ($search, github) ->
  return unless github
  _(calculateResults(github)).tap (results) ->
    render('results', results, $search.find('[data-js-results]'))
    $('[data-js-overall-grade]').removeClass('invisible')
    $('[data-js-overall-grade-letter]').text(results.overall)
    $('[data-js-results-marker]').addClass('results-ready')
    setTimeout ->
      $('[data-js-percentage]').each (i, el) ->
        $(el).css(width: "#{results.grades[i].percentage}%")
    , 400

unrenderResults = ->
  $('[data-js-overall-grade]').addClass('invisible')
  $('[data-js-results-marker]').removeClass('results-ready')

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
    percentage: percentage = randomPercentage()
    letter: letterGradeFromPercentage(percentage)


pickCriteria = ->
  _([
    "Thoughtfulness of Naming",
    "Expressiveness of Tests",
    "Empathy for Maintainers",
    "Future-proof Avoidance",
    "Conscientious Logging",
    "Commit Message Clarity"
  ]).chain().shuffle().first(5).value()

randomPercentage = ->
  _.random(40, 100)

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

letterGradeFromPercentage = (percentage) ->
  _(LETTER_GRADES).find (grade, cutoff) ->
    percentage <= parseInt(cutoff, 10)

## 3. public static void main()
$ ->
  renderSearch()
  handleResize()
  $('form').on('submit', -> generateReportCardFor($('[data-js-search-input]').val()))
  $(window).on('resize', handleResize)
  $(window).on('hashchange', -> generateReportCardFor(githubQuery()))
