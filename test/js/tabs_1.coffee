$ ->
	addTestButton "Test Tabs", "Open", (e)->
		addHolder("renderTest1");
		tabs = new DynamicTabs("#renderTest1")
		tabs.addTab "Test 1", "Default One"
		tabs.addTab "Test 2", "Default Two"

		return 1

	addTestButton "Test Tabs with order", "Open", (e)->
		addHolder("renderTest1");
		tabs = new DynamicTabs("#renderTest1")
		tabs.addTabData "Test 1", "Default One"
		tabs.addTabData "Test 2", "Default Two", 1
		tabs.addTabData "Test 3", "Default Three", 0
		tabs.addTabData "Test 4", "Default Four"
		tabs.addTabData "Test 5", "Default Five", 2
		tabs.addSortedTags("tab").next()

		return 1

	addTestButton "Test Tabs order/setTimeout", "Open", (e)->
		addHolder("renderTest1");
		tabs = new DynamicTabs("#renderTest1")
		setTimeout ->
			tabs.addTabData "Test 1", "Default One"
		, 100
		setTimeout ->
			tabs.addTabData "Test 2", "Default Two", 1
		, 200
		setTimeout ->
			tabs.addTabData "Test 3", "Default Three", 0
		, 300
		setTimeout ->
			tabs.addTabData "Test 4", "Default Four"
		, 400
		setTimeout ->
			tabs.addTabData "Test 5", "Default Five", 2
		, 500
		setTimeout ->
			tabs.addSortedTags("tab").next()
		, 1000
		return 1

	addTestButton "Test Tabs with badge", "Open", (e)->
		addHolder("renderTest1");
		tabs = new DynamicTabs("#renderTest1")
		tab1 = tabs.addTab "Test 1", "Default One"
		tab2 = tabs.addTab "Test 2", "Default Two"
		tab1.setBadge(5)
		return 1

	addTestButton "Test Tabs with badge with context classes", "Open", (e)->
		addHolder("renderTest1");
		tabs = new DynamicTabs("#renderTest1")
		tab1 = tabs.addTab "Test 1", "Default One"
		tab2 = tabs.addTab "Test 2", "Default Two"
		tab1.setBadge(5,'warning')
		tab2.setBadge(2,'danger','back') ## direction of the badge it can be front (default) or back
		return 1

	addTestButton "Tabs with tables", "Open", (e)->
		addHolder("renderTest1")
		$("#renderTest1").height(800)

		newPromise ()->

			yield loadZipcodes()
			yield loadStockData()

			tabs = new DynamicTabs("#renderTest1")
			tabs.elHolder.width 1000
			tabs.elHolder.height 800
			tabs.doAddTableTabData "zipcode", "Zipcodes", 1
			tabs.doAddTableTabData "stocks", "Stock Data", 0

			yield from tabs.addSortedTags "tableTab"

		.then ()->
			console.log "Done."

	go()
