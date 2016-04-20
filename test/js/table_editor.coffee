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

	addTestButton "create table column editor in popup", 'Open', () ->
		##| not created holder because PopupTable will create holder for us in popup automatically
		addHolder('renderTest1')
		te = new TableEditor $('#rendderTest1'), "geoset", false # give false as 3rd argument to stop automatic rendering
		popup = new PopupTable te.getTableInstance(), 'geosetColumnEditor'
		# make sure to bind after render is done otherwise parent popup element will not be found!
		# also because tableEditor gets 120 as column width so we give thresold as 121 so all columns having width less than 121 can be hidden
		te.getTableInstance().setAutoHideColumn(121);
	go()
