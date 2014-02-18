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
      includeZero: true
      delimiter: ';'
      rollPeriod: 1
      showRoller: true
      digitsAfterDecimal: 3
      strokeWidth: 1
      labels: ['Time', 'value']
    )

  create: ->
    @loadFile(@url).then(@parseXml).then(@draw)

  update: ->
    @loadFile(@url).then(@parseXml).then =>
      @graph.updateOptions file: @data

$ ->
  g1 = new Graph
    name: 'BWP'
    url: '/stats/8145ccd1-7eb6-11e3-8871c2aa1a975e8c.201401.xml'
    div: 'graph1'

  g2 = new Graph
    name: 'Entfeuchter'
    url: '/stats/d1566d63-84ff-11e3-bcf9cf3dda222cab.201401.xml'
    div: 'graph2'

  g1.create()
  g2.create()

  $('#graph1').click ->
    g1.update()
