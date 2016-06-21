Highcharts = require 'highcharts/highstock'
require('highcharts/highcharts-more')(Highcharts)
require('highcharts/modules/solid-gauge')(Highcharts)
_          = require 'lodash'

generalGaugeOptions =
  chart:
    type: 'solidgauge'
  title: null
  pane:
    center: ['50%', '85%']
    size: '75%'
    startAngle: -90
    endAngle: 90
    background:
      backgroundColor: Highcharts.theme and Highcharts.theme.background2 or '#EEE'
      innerRadius: '60%'
      outerRadius: '100%'
      shape: 'arc'
  tooltip: enabled: false
  yAxis:
    stops: [
      [0.1, '#55BF3B']
      [0.5, '#DDDF0D']
      [0.9, '#DF5353']
    ]
    lineWidth: 0
    minorTickInterval: null
    tickPixelInterval: 800
    tickWidth: 0
    title: y: -110
    labels: y: 15
  plotOptions: solidgauge: dataLabels:
    y: 5
    borderWidth: 0
    useHTML: true

addGaugeOptions = (axisLabel, actual, total, unit) ->
  series:[
    name: axisLabel
    animation: false
    data: [actual]
    dataLabels:
      format: '<div style="text-align:center"><span style="font-size:25px;color:' +
        (Highcharts.theme and Highcharts.theme.contrastTextColor or 'black') +
        '">{y}</span><br/>' +
        '<span style="font-size:12px;color:silver">' + unit + '</span></div>'
  ]
  credits: enabled: false
  yAxis:
    title: text: axisLabel
    min: 0, max: total

Template.index.helpers
  projectName: -> Settings.get('project').toUpperCase()
  appVersion: -> Helper.appVersion()
  appCount: -> ApplicationDefs.find().count()
  instanceCount: -> Instances.find().count()
  activeInstanceCount: -> Instances.find('meta.state': 'active').count()
  inactiveInstanceCount: -> Instances.find('meta.state': $not: 'active').count()
  tags: ->
    defs = ApplicationDefs.find({tags: $not: undefined}, fields: tags: 1).fetch()
    tagsAndCount = _.reduce defs, (memo, def) ->
      for tag in def.tags
        if memo[tag] then memo[tag] += 1 else memo[tag] = 1
      memo
    , {}
    tag: k, count: v for k,v of tagsAndCount
  createChart: ->
    systemStatus = _.fromPairs Swarm.findOne().swarm.SystemStatus
    systemStatus = _.mapKeys systemStatus, (value, key) ->
      key.replace(/[\u2514]+/g, '').trim()
    console.log systemStatus['Reserved Memory']
    [match, minMem, minUnit, maxMem, maxUnit] = /([\d|\.]+)\s(\w+)\s\/\s([\d|\.]+)\s(\w+)/.exec systemStatus['Reserved Memory']
    reservedCpu = /(\d)\s\/\s(\d)/.exec systemStatus['Reserved CPUs']
    Meteor.defer ->
      Highcharts.chart 'reservedMemory', Highcharts.merge(generalGaugeOptions, addGaugeOptions('Reserved Memory', parseFloat(minMem), parseFloat(maxMem), minUnit))
      Highcharts.chart 'reservedCpu', Highcharts.merge(generalGaugeOptions, addGaugeOptions('Reserved CPUs', parseInt(reservedCpu[1]), parseInt(reservedCpu[2]), "CPUs"))

Template.index.events
  'click .restart-tag': (e, tpl) -> Meteor.call 'restartTag', @tag
