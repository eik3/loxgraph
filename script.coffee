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

class Stat
  @get_stats: ->
    $('#js-datastore').data('statArray')

  @stat_exists: (source) ->
    $.inArray(source, $('#js-datastore').data('statArray'))

  @loadFile: ->
    $.ajax
      url: '/stats/'
      dataType: 'html'

  @parseHtml: (htmlDoc) =>
    statArray = $(htmlDoc).find('li>a').map ->
      url = $(this).attr('href')
      urlRe = /([0-9a-f-]{35})\.([0-9]{6})\.xml/
      source = url.replace(urlRe, "$1")
      period = url.replace(urlRe, "$2")
      year = period.slice 0,4
      month = period.slice -2
      titleRe = /(.*) \((.*)\) [0-9]{6}/
      title = $(this).text().replace(titleRe, "$1")
      categoryAndRoom = $(this).text().replace(titleRe, "$2")

      if source of Stat.get_stats() # CoffeeScript 'of' equals JS 'in'
        data = Stat.get_stats()[source]
        data.urls.push {url, year, month}
        $('#js-datastore').data('statArray', obj)
      else
        obj = Stat.get_stats()
        obj[source] = {title, categoryAndRoom, urls: [{url, year, month}]}
        $('#js-datastore').data('statArray', obj)

  @createMenu: ->
    #obj = Stat.get_stats()
    #$('body').append("<pre>#{JSON.stringify(obj,undefined,2)}</pre>")
    $('#menu-container').append("<ul></ul>")
    for k, v of Stat.get_stats()
      $('#menu-container>ul').append("<li id=#{k}>#{v.title}<ul></ul></li>")
      for u in v.urls
        $("#menu-container>ul>li[id=#{k}]>ul").append("<li><a href=#{u.url}>#{u.year} #{u.month}</a></li>")


  @go: ->
    $('#js-datastore').data('statArray', {})
    @loadFile().then(@parseHtml).done(@createMenu)

$ ->
  $(document).keydown (event) ->
    switch event.keyCode
      when 32 # space
        console.log 'get_stats', Stat.get_stats()[0].title
      when 67 # c
        console.log 'create'
      when 82 # r
        console.log 'read'

  Stat.go()

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
