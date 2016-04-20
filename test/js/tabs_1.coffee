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

	go()
