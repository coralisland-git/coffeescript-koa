$ ->
	addTestButton "Test Tabs", "Open", (e)->
		addHolder("renderTest1");
		tabs = new DynamicTabs("#renderTest1")
		tabs.addTab "Test 1", "Default One"
		tabs.addTab "Test 2", "Default Two"

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
			yield tabs.doAddTableTab "zipcode", "Zipcodes"
			yield tabs.doAddTableTab "stocks", "Stock Data"

		.then ()->
			console.log "Done."

	go()
