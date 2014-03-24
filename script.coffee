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
    $("##{@div}").width($(window).width() - $("##{@div}").css('margin').replace(/[^-\d\.]/g, '')*4)
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

      if sourceId of stats # CoffeeScript 'of' equals JS 'in'
        stats[sourceId].urls.push {url, year, month}
      else
        stats[sourceId] = {title, categoryAndRoom, urls: [{url, year, month}]}

    return stats

  @createMenu: (stats) ->
    $('#menu-container').append('<ul></ul>')
    for sourceId, source of stats
      $('#menu-container>ul').append("<li id=#{sourceId}>#{source.title}<ul></ul></li>")
      for u in source.urls
        divId = "#{sourceId}_#{u.year}#{u.month}"
        $("#menu-container>ul>li[id=#{sourceId}]>ul")
          .append("<li><a title='show/hide graph for #{u.year} #{u.month}'
            href='javascript:void(0)'
            data-div-id=#{divId}
            data-url=#{u.url}
            data-title=\"#{source.title}: #{u.year}-#{u.month}\">#{u.year}-#{u.month}</a></li>")
    $('#menu-container a').click ->
      # TODO move remaining code into Graph method
      divId = $(this).attr('data-div-id')
      if $(this).hasClass('selected')
        $("##{divId}").parent().remove()
      else
        $('#graph-container').append("<div class=dygraph-wrapper>
          <a title=close data-div-id=#{divId} class=close-graph href='javascript:void(0)'>x</a>
          <div class=dygraph id=#{divId}><span class=loading>loading</span></div>
          </div")
        g = new Graph
          name: $(this).attr('data-title')
          url: $(this).attr('data-url')
          div: divId
        .create()

      $('.close-graph').click (event) ->
        event.preventDefault()
        $(this).parent().remove()
        dataDivId = $(this).attr('data-div-id')
        $("#menu-container a[data-div-id=#{dataDivId}]").removeClass('selected')

      $(this).toggleClass('selected')

  @go: ->
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
