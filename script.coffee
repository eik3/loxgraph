class Graph
  constructor: (options) ->
    {@name, @div, @url} = options

  data = undefined
  graph = undefined

  loadFile: (url) ->
    $.ajax
      url: url
      dataType: 'text'

  parseXml: (xmlDoc) =>
    @data = $(xmlDoc).find('S').map ->
      timestamp = new Date($(this).attr('T'))
      value = parseFloat($(this).attr('AI1'))
      [[timestamp, value]]
    .toArray()

  draw: (d) =>
    @graph = new Dygraph($("##{@div}")[0], d,
      dateWindow: [(new Date().valueOf())-86400000,new Date().valueOf()]
      delimiter: ';'
      digitsAfterDecimal: 3
      includeZero: true
      labels: ['Time', 'value']
      rollPeriod: 1
      showRoller: true
      strokeWidth: 1
    )

  create: ->
    @loadFile(@url).then(@parseXml).then(@draw)
    $("##{@div}").width($(window).width() - $("##{@div}").css('margin').replace(/[^-\d\.]/g, '')*4)

  update: ->
    @loadFile(@url).then(@parseXml).then =>
      @graph.updateOptions file: @data

  zoomRight: ->
    @graph.updateOptions
      dateWindow: [(new Date().valueOf())-86400000,new Date().valueOf()]

  adjustWidth: ->
    $("##{@div}").width($(window).width() - $("##{@div}").css('margin').replace(/[^-\d\.]/g, '')*4)

$ ->
  g1 = new Graph
    name: 'BWP'
    url: '/stats/8145ccd1-7eb6-11e3-8871c2aa1a975e8c.201403.xml'
    div: 'graph1'

  g2 = new Graph
    name: 'Entfeuchter'
    url: '/stats/d1566d63-84ff-11e3-bcf9cf3dda222cab.201403.xml'
    div: 'graph2'

  g1.create()
  g2.create()

  setInterval (->
    console.log Date()
    graph.update() for graph in [g1, g2]
    graph.zoomRight() for graph in [g1, g2]
  ), 5 * 60 * 1000

  $(window).resize ->
    graph.adjustWidth() for graph in [g1, g2]
