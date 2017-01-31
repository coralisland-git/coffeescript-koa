##| sample miller data	
MillerData =
	'categoryId': 'cat-1'
	'categoryName': 'Category 1'
	'parentId': null
	'isLowestLevel': true
	'items': [
		{
			'itemId': 'item-1'
			'isDeleteable': true
			'itemName': 'Category 1 item 1'
			'hasChildren': true
			'categoryId': 'cat-1'
			'parentId': null
		}
		{
			'itemId': 'item-2'
			'isDeleteable': true
			'itemName': 'Category 1 item 2'
			'hasChildren': true
			'categoryId': 'cat-1'
			'parentId': 'item-1'
		}
		{
			'itemId': 'item-3'
			'isDeleteable': true
			'itemName': 'Category 1 item 2 item 3'
			'hasChildren': false
			'categoryId': 'cat-1'
			'parentId': 'item-2'
		}
		{
			'itemId': 'item-4'
			'isDeleteable': true
			'itemName': 'Category 1 item 2 item 3'
			'hasChildren': false
			'categoryId': 'cat-1'
			'parentId': 'item-3'
		}
	]


$ ->

	##|
	##|  Simple miller column using this
	##|
    addTestButton "Miller Columns", "Open", ()->

    	div = addHolderWidget("renderTest1")
    	div.setView "Miller", (view)=>
    		view.setData(MillerData)
    		view.show()
    		view.millerColumn.onSelected = (e, data) ->
    			console.log('custom event callback from miller column', data)

    ##|
    ##|  Simple miller column using this
    ##|
    addTestButton "Miller Columns popup", "Open", ()->
    	doPopupView('Miller', 'Miller Columns', 'miller_popup', 1000, 450).then (view) ->
    		## remove existing millerColumn instance to force render in popup
    		delete view.millerColumn
    		view.setData(MillerData)
    		view.show()
    		view.millerColumn.onSelected = (e, data) ->
    			console.log('custom event callback from miller column', data)

	##|
    ##|  Simple miller column using this
    ##|
    addTestButton "Miller Columns tab", "Open", ()->
    	addHolder('renderTest1')
    	tabs = new DynamicTabs('#renderTest1')
    	tabs.addTab "Test 1", '<div id="miller-container"></div>'
    	tabs.addTab "Test 2", '<h2>Another tab</h2>'
    	## load miller.js externally as it is loaded with view only
    	## to use MillerColumn without view miller.js needs to be loaded externally
    	$.getScript '/vendor/miller.min.js'
            .then ->
		    	millerColumn = new MillerColumns $('#miller-container'), true
		    	millerColumn.setData MillerData
		    	millerColumn.render()
    go()