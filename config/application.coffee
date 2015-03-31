# Exports a function which returns an object that overrides the default &
#    plugin grunt configuration object.
#
#  You can familiarize yourself with Lineman's defaults by looking at:
#
#    - https://github.com/linemanjs/lineman/blob/master/config/application.coffee
#    - https://github.com/linemanjs/lineman/blob/master/config/plugins
#
#  You can also ask about Lineman's  config from the command line:
#
#    $ lineman config #=> to print the entire config
#    $ lineman config concat_sourcemap.js #=> to see the JS config for the concat task.
#
module.exports = (lineman) ->
  app = lineman.config.application;

  loadNpmTasks: app.loadNpmTasks.concat("grunt-sass")

  prependTasks:
    common: app.prependTasks.common.concat("sass")
