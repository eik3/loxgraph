window.Loxgraph = {}

class Loxgraph.Graph
  constructor: (options) ->
    {@name, @div, @data} = options

  graph = undefined

  draw: =>
    @graph = new Dygraph($("##{@div}")[0], @data,
      delimiter: ';'
      digitsAfterDecimal: 3
      labels: ['Time', 'value']
      rightGap: 20
      rollPeriod: 1
      showRoller: true
      strokeWidth: 1
      title: @name
    )
    # @zoomLastMinutes 1440

  create: ->
    @draw()
    # @adjustWidth()
    return this

  # update not yet working!
  # update: ->
  #   @loadFile().then(@parseXml).then =>
  #     @graph.updateOptions file: @data

  zoomLastMinutes: (minutes=120) ->
    now = new Date().valueOf()
    intervalBegin = now - minutes * 1000 * 60
    intervalEnd   = now
    @graph.updateOptions
      dateWindow: [intervalBegin, intervalEnd]

  moveDateWindowRight: ->
    [currBegin, currEnd] = @graph.xAxisRange()

    now = new Date().valueOf()
    diff = now - currEnd

    @graph.updateOptions
      dateWindow: [currBegin + diff, currEnd + diff]

  adjustWidth: ->
    $("##{@div}").width($(window).width() - $("##{@div}").css('margin').replace(/[^-\d\.]/g, '')*4)

class Loxgraph.Stat
  @loadFile: -> $.ajax { url: '/stats', dataType: 'html' }

  @parseHtml: (htmlDoc) =>
    stats = {}
    $(htmlDoc).find('li>a').sort().map ->
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
    ractive.set 'stats', stats
    stats

  @parseXML: (sourceId, xmlDoc) =>
      ractive.set 'progress', ((ractive.get 'current') / (ractive.get 'total') * 100).toFixed(0)
      parsedData = $(xmlDoc).find('S').map ->
        dateString = $(this).attr('T')
        # ugly hack to fix date parsing differences between chrome & firefox
        dateString = dateString.replace(' ', 'T') if /Firefox/.test(navigator.userAgent)
        # /hack
        timestamp = new Date(dateString)
        value = parseFloat($(this)[0].attributes[1].value)
        [[timestamp, value]]
      .toArray()
      if sourceId of window.Loxgraph.sourceData
        Array::push.apply window.Loxgraph.sourceData[sourceId], parsedData
      else
        window.Loxgraph.sourceData[sourceId] = parsedData

  @processQueue: (queue, callback) ->
    if queue.length
      ractive.add 'current'
      $.ajax(
        dataType: 'xml'
        url: "/stats/#{queue[0].url}"
      ).done (data) =>
        @parseXML queue[0].sourceId, data
        @processQueue queue.slice(1), callback
    else
      callback()

  @buildArray: (stats) =>
    queue = []
    ractive.set 'progress', 0
    ractive.set 'loading', true
    window.Loxgraph.sourceData = {}
    for sourceId, source of stats
      for url in source.urls
        ractive.add 'total'
        queue.push {sourceId: sourceId, url: url.url}
    @processQueue queue, ->
      # queue is finished, everything loaded successfully
      ractive.set 'loading', false # hides progress bar, shows menu

  @go: ->
    @loadFile().then(@parseHtml).then(@buildArray)

Loxgraph.Stat.go()

graphs = []

ractive = new Ractive
  el: 'output'
  template: '#template'
  data: graphs

ractive.on
  select: (event, title, sourceId) ->
    kp = @get "#{event.keypath}"
    @toggle "#{event.keypath}.selected"
    if kp.selected
      graphs[event.keypath] = new Loxgraph.Graph
        name: title
        data: window.Loxgraph.sourceData[sourceId]
        div: sourceId
      .create()
  # update not yet working!
  # update: (event) ->
  #   kp = @get "#{event.keypath}"
  #   graphs[kp.divId].update()
  #   graphs[kp.divId].moveDateWindowRight()
