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
    console.log @div
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
    @loadFile("/stats/#{@url}").then(@parseXml).then(@draw)
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
    $('#js-datastore').data('stats')

  @loadFile: ->
    $.ajax
      url: '/stats'
      dataType: 'html'

  @parseHtml: (htmlDoc) =>
    $(htmlDoc).find('li>a').map ->
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
        $('#js-datastore').data('stats', obj)
      else
        obj = Stat.get_stats()
        obj[source] = {title, categoryAndRoom, urls: [{url, year, month}]}
        $('#js-datastore').data('stats', obj)

  @createMenu: ->
    $('#menu-container').append("<ul></ul>")
    for k, v of Stat.get_stats()
      $('#menu-container>ul').append("<li id=#{k}>#{v.title}<ul></ul></li>")
      for u in v.urls
        $("#menu-container>ul>li[id=#{k}]>ul")
          .append("<li><span data-url=#{u.url}>#{u.year} #{u.month}</span></li>")
    $('#menu-container span').click ->
      $('#menu-container span').removeClass()
      $(this).addClass('selected')
      # TODO move remaining code into Graph method
      id = $(this).attr('data-url').replace(/\./g, '_') # '.' in id breaks jQuery!
      $('#graph-container').append("<div class=dygraph-wrapper>
        <a title=close data-graph-id=#{id} class=close-graph href=''>x</a>
        <div class=dygraph id=#{id}></div>
        </div")
      g = new Graph
        name: 'foo'
        url: $(this).attr('data-url')
        div: id
      .create()
      $('.close-graph').click (event) ->
        event.preventDefault()
        $(this).parent().remove()

  @go: ->
    $('#js-datastore').data('stats', {})
    @loadFile()
      .then(@parseHtml)
      .then(@createMenu)

$ ->
  Stat.go()


###
  $(window).resize ->
    $('.dygraph')
  g1 = new Graph
    name: 'BWP'
    url: '/stats/8145ccd1-7eb6-11e3-8871c2aa1a975e8c.201403.xml'
    div: 'graph1'

  g2 = new Graph
    name: 'Entfeuchter'
    url: '/stats/d1566d63-84ff-11e3-bcf9cf3dda222cab.201403.xml'
    div: 'graph2'

  #g1.create()
  #g2.create()

  setInterval (->
    console.log Date()
    graph.update() for graph in [g1, g2]
    graph.zoomRight() for graph in [g1, g2]
  ), 5 * 60 * 1000

  $(document).keydown (event) ->
    switch event.keyCode
      when 32 # space
        console.log 'get_stats', Stat.get_stats()[0].title
      when 67 # c
        console.log 'create'
      when 82 # r
        console.log 'read'
###
