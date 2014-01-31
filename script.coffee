$ ->
  u1 = '/stats/8145ccd1-7eb6-11e3-8871c2aa1a975e8c.201401.xml' #twp
  u2 = '/stats/d1566d63-84ff-11e3-bcf9cf3dda222cab.201401.xml' #dhf

  doajax = (url) ->
    $.ajax
      url: url
      dataType: 'html'
      success: (response) ->
        parse response

  parse = (response) ->
    xmlDoc = $.parseXML(response)
    xml = $(xmlDoc)
    arr = []
    xml.find('S').each ->
      timestamp = new Date($(this).attr('T'))
      value = parseFloat($(this).attr('AI1'))
      arr.push [timestamp, value]
    draw arr

  draw = (data) ->
    new Dygraph($('#graph1')[0], data,
      includeZero: true
      delimiter: ';'
      rollPeriod: 1
      showRoller: true
      digitsAfterDecimal: 3
      strokeWidth: 1
      labels: ['Time', 'value']
    )

  doajax u1

  #doit(u2, div2)


  ###
  draw = ->
    new Dygraph($('#graph')[0], $obj,
      includeZero: true
      delimiter: ';'
      rollPeriod: 1
      showRoller: true
      strokeWidth: 1
    )
  ###

  #g = draw()

  $('#p1').change ->
    g.updateOptions file: buildURL()

  $('#plus').click ->
    g.updateOptions rollPeriod: 1

  rollPeriodUp = ->
    g.updateOptions rollPeriod: g.rollPeriod() * 2 if g.rollPeriod() < 512

  rollPeriodDown = ->
    g.updateOptions rollPeriod: g.rollPeriod() / 2 if g.rollPeriod() > 1

    $(document).keydown (event) ->
        switch event.keyCode
            when 37 # cursor left
              console.log g.rollPeriod()
            when 39 # cursor right
                x += 10
            when 38 # cursor up
              rollPeriodUp()
            when 40 # cursor down
              rollPeriodDown()
            when 187 # +
                size += 5
            when 189 # -
                size -= 5
