$ ->

  addTestButton "create table column editor for zipcode", 'Open', () ->
    addHolder('renderTest1')
    te = new TableEditor $("#renderTest1"), "zipcode" # table key is required to identify the current configuration of columns

  addTestButton "create table column editor with oncreate callback", 'Open', () ->
    addHolder('renderTest1')
    te = new TableEditor $("#renderTest1"), "zipcode" # table key is required to identify the current configuration of columns
    te.onCreate = (data) ->
      console.log data
      true

  addTestButton "create table column editor for geoset", 'Open', () ->
    addHolder('renderTest1')
    te = new TableEditor $("#renderTest1"), "geoset" # table key is required to identify the current configuration of columns
  go()