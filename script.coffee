class Graph
  constructor: (options) ->
    {@name, @div, @url} = options

  data = undefined
  graph = undefined

  loadFile: (url) -> $.ajax { url: url, dataType: 'xml' }

  parseXml: (xmlDoc) =>
    @data = $(xmlDoc).find('S').map ->
      timestamp = new Date($(this).attr('T'))
      value = parseFloat($(this).attr('AI1'))
      [[timestamp, value]]
    .toArray()

  draw: (d) =>
    @graph = new Dygraph($("##{@div}")[0], d,
      delimiter: ';'
      digitsAfterDecimal: 3
      includeZero: true
      labels: ['Time', 'value']
      rollPeriod: 1
      showRoller: true
      strokeWidth: 1
      title: @name
    )

  create: ->
    @loadFile("/stats/#{@url}").then(@parseXml).then(@draw)
    @adjustWidth()
    return this

  update: ->
    @loadFile(@url).then(@parseXml).then =>
      @graph.updateOptions file: @data

  zoomLastMinutes: (minutes=120) ->
    now = new Date().valueOf()
    intervalBegin = now - minutes * 1000 * 60
    intervalEnd   = now
    console.log [intervalBegin, intervalEnd]
    @graph.updateOptions
      dateWindow: [intervalBegin, intervalEnd]

  adjustWidth: ->
    $("##{@div}").width($(window).width() - $("##{@div}").css('margin').replace(/[^-\d\.]/g, '')*4)

class Stat
  @loadFile: -> $.ajax { url: '/stats', dataType: 'html' }

  @parseHtml: (htmlDoc) =>
    stats = {}
    $(htmlDoc).find('li>a').map ->
      url = $(this).attr('href')
      urlRe = /([0-9a-f-]{35})\.([0-9]{6})\.xml/
      sourceId = url.replace(urlRe, '$1')
      period = url.replace(urlRe, '$2')
      year = period.slice 0,4
      month = period.slice -2
      titleRe = /(.*) \((.*)\) [0-9]{6}/
      title = $(this).text().replace(titleRe, '$1')
      categoryAndRoom = $(this).text().replace(titleRe, '$2')
      divId = "#{sourceId}_#{year}#{month}"
      urlObj = {url, year, month, divId, selected: false}

      if sourceId of stats # CoffeeScript 'of' equals JS 'in'
        stats[sourceId].urls.push urlObj
      else
        stats[sourceId] = {title, categoryAndRoom, urls: [urlObj]}

    ractive.set stats: stats

  @go: ->
    @loadFile().then(@parseHtml)

Stat.go()

ractive = new Ractive
  el: 'output'
  template: '#template'

ractive.on
  select: (event, url, title) ->
    kp = @get "#{event.keypath}"
    @toggle "#{event.keypath}.selected"
    if kp.selected
      new Graph
        name: "#{title} #{kp.year}-#{kp.month}"
        url: kp.url
        div: kp.divId
      .create()
