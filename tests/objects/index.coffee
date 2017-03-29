_ = require 'lodash'

objects = {}

module.exports = ->
  _.assign(objects, require('./navigation'))
  _.assign(objects, require('./instances'))
  _.assign(objects, require('./apps'))
  _.assign(objects, require('./storage'))
