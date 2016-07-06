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


	testObj = {"id":{"name":"ID","source":"id","visible":true,"hideable":true,"type":"int","width":40,"tooltip":""},"_lastModified":{"name":"Modified","source":"_lastModified","visible":false,"hideable":true,"type":"timeago","width":100,"tooltip":""},"server_name":{"name":"Title","source":"server_name","visible":true,"hideable":true,"type":"text","width":100,"tooltip":""},"username":{"name":"Username","source":"username","visible":true,"hideable":true,"type":"text","width":100,"tooltip":""},"password":{"name":"Password","source":"password","visible":false,"hideable":true,"type":"text","width":100,"tooltip":""},"useragent":{"name":"User Agent","source":"useragent","visible":false,"hideable":true,"type":"enum","width":80,"tooltip":""},"useragent_password":{"name":"UA Password","source":"useragent_password","visible":false,"hideable":true,"type":"text","width":100,"tooltip":""},"version":{"name":"Version","source":"version","visible":false,"hideable":true,"type":"enum","width":70,"tooltip":""},"metro_area":{"name":"Metro Area","source":"metro_area","visible":true,"hideable":true,"type":"text","width":70,"tooltip":""},"active":{"name":"Active","source":"active","visible":true,"hideable":true,"type":"boolean","width":60,"tooltip":""},"loginStatus":{"name":"Verified","source":"loginStatus","visible":true,"hideable":true,"type":"boolean","width":60,"tooltip":""},"is_off_market":{"name":"Off Market","source":"is_off_market","visible":true,"hideable":true,"type":"boolean","width":60,"tooltip":""},"force_post":{"name":"Use POST","source":"force_post","visible":true,"hideable":true,"type":"boolean","width":60,"tooltip":""},"metadataVersion":{"name":"Metadata Ver","source":"metadataVersion","visible":true,"hideable":true,"type":"text","width":80,"tooltip":""},"classes":{"name":"Classes","source":"classes","visible":true,"hideable":true,"type":"int","width":60,"tooltip":"","render":"function (val, obj) {\n      var count;\n      count = Object.keys(val).length;\n      return count;\n    }"},"url":{"name":"URL","source":"url","visible":true,"hideable":true,"type":"text","width":100,"tooltip":""},"total_active":{"name":"Total Active","source":"total_active","visible":true,"hideable":true,"type":"int","width":70,"tooltip":""},"total_properties":{"name":"Total Records","source":"total_properties","visible":true,"hideable":true,"type":"int","width":70,"tooltip":""}}
	DataMap.importDataTypes "test", testObj

	go()
