$ ->

	addTestButton "Test Tabs", "Open", (e)->

		addHolder("renderTest1")
		.setView "DynamicTabs", (tabs)->
			tabs.addTab "Test 1", "Default One"
			tabs.addTab "Test 2", "Default Two"

		return 1

	addTestButton "Test Tabs with order", "Open", (e)->

		addHolder("renderTest1")
		.setView "DynamicTabs", (tabs)->
			tabs.addTab "Test 1", "Default One"
			tabs.addTab "Test 2", "Default Two", 1
			tabs.addTab "Test 3", "Default Three", 0
			tabs.addTab "Test 4", "Default Four"
			tabs.addTab "Test 5", "Default Five", 2

		return 1

	addTestButton "Test Tabs order/setTimeout", "Open", (e)->

		addHolder("renderTest1")
		.setView "DynamicTabs", (tabs)->
			setTimeout ->
				console.log "Added 0"
				tabs.addTab "Test 0", "Default One", 0
			, (2000 * Math.random())
			setTimeout ->
				console.log "Added 1"
				tabs.addTab "Test 1", "Default Two", 1
			, (2000 * Math.random())
			setTimeout ->
				console.log "Added 2"
				tabs.addTab "Test 2", "Default Three", 2
			, (2000 * Math.random())
			setTimeout ->
				console.log "Added 3"
				tabs.addTab "Test 3", "Default Four", 4
			, (2000 * Math.random())
			setTimeout ->
				console.log "Added 4"
				tabs.addTab "Test 4", "Default Five", 5
			, (2000 * Math.random())

		return 1

	addTestButton "Test Tabs with badge", "Open", (e)->

		addHolder("renderTest1")
		.setView "DynamicTabs", (tabs)->
			tab1 = tabs.addTab "Test 1", "Default One"
			tab2 = tabs.addTab "Test 2", "Default Two"
			tab1.setBadge(5)

		return 1

	addTestButton "Test Tabs with badge with context classes", "Open", (e)->

		addHolder("renderTest1")
		.setView "DynamicTabs", (tabs)->
			tab1 = tabs.addTab "Test 1", "Default One"
			tab2 = tabs.addTab "Test 2", "Default Two"
			tab1.setBadge(5,'warning')
			tab2.setBadge(2,'danger','back') ## direction of the badge it can be front (default) or back

		return 1

	addTestButton "Tabs with tables", "Open", (e)->

		newPromise ()->

			yield loadZipcodes()
			yield loadStockData()
			tabs = yield addHolder().setView "DynamicTabs"
			tabs.doAddTableTab "zipcode", "Zipcodes", 1
			tabs.doAddTableTab "stocks", "Stock Data", 0

		.then ()->
			console.log "Done."

	go()
