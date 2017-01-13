
## -------------------------------------------------------------------------------------------------------------
## class to create tabs dynamically
##
## @example
##      tabs = new DynamicTabs("#elementId")
##      tabs.addTab("Tab Title", "Tab Content")
##
class DynamicTabs

	## -------------------------------------------------------------------------------------------------------------
	## constructor new tab instance
	##
	## @param [String] the id of the element in which tab should be rendered
	##
	constructor: (holderElement)->

		@tags       = {}
		@tabs       = {}
		@tabCount   = 0
		@activeTab  = null
		@elHolder   = new WidgetTag("div", "ninja-tabs")
		@tabList    = @elHolder.add "ul", "ninja-tab-list"
		@elHolder.addDiv "clr"
		@tabContent = @elHolder.add "div", "ninja-tab-content tab-content"
		@tabData  	= []

		$(holderElement).append @elHolder.el

		GlobalClassTools.addEventManager(this)
		globalTableEvents.on "row_count", @onCheckTableUpdateRowcount

	onSetBadge: (num, classname)->
		id = this.id
		# console.log "onSetBadge num=#{num} classname=#{classname}", id, this.parent
		@parent.tags[id].badge = num
		@parent.tags[id].badgeText.addClass classname
		@parent.updateTabs()

	onClickTab: (e)=>
		console.log "dnymictabs onClicktab"
		if e? and e.path? then @show(e.path)
		return true

	getActiveTab: ()=>
		return @tags[@activeTab]

	show: (id)=>
		console.log "dynamic tabs show #{id}"
		if !id? then return false
		if typeof id == "object" and id.id? then id = id.id
		if @tags[id]?
			@emitEvent "showtab", [ id, @tags[id] ]
			@activeTab = id
			@updateTabs()
		else
			console.log "Warning: DynamicTabs show(#{id}) invalid tab"
		return true

	getTab: (tabName) =>

		##|
		##|  Return existing tab
		if @tabs[tabName]? then return @tabs[tabName]
		return null

	## -------------------------------------------------------------------------------------------------------------
	## Add a new tab to current instance
	##
	## @param [String] tabName the name of the tab to be adding
	## @param [String] defaultHtml optional html for the tab content
	## @return [Tab] the new tab Object which is created
	##
	addTab: (tabName, defaultHtml) =>

		##|
		##|  Return existing tab
		if @tabs[tabName]? then return @tabs[tabName]

		id = "tab#{@tabCount++}"

		elTab = @tabList.add "li", "ninja-nav-tab"
		elTab.setDataPath id
		elTab.on "click", @onClickTab

		elTabText = elTab.add "div", "ninja-tab-text"
		elTabText.html tabName

		elTabBadge = elTab.addDiv "ninja-badge"

		elBody = @tabContent.add "div", "ninja-nav-body"
		elBody.html defaultHtml

		if !@activeTab?
			@activeTab = id

		@tags[id] =
			name:      tabName
			id:        id
			parent:    this
			tab:       elTab
			body:      elBody
			tabText:   elTabText
			badgeText: elTabBadge
			setBadge:  @onSetBadge
			show: ()=>
				@activeTab = id
				@updateTabs()

		##|
		##|  A reference to the data by name
		@tabs[tabName] = @tags[id]

		@updateTabs()

		return @tags[id]
	## -------------------------------------------------------------------------------------------------------------
	## Add a new tab data to array named "tabData"
	##
	## @param [String] tabName the name of the tab to be adding
	## @param [String] defaultHtml optional html for the tab content
	## @param [Integer] order (optional) order of the tab that should >= 0, if not specified, set it to -1
	## @return [Tab] the new tab Object which is created
	##
	addTabData: (tabName, defaultHtml, order) =>
		if order == undefined
			order = -1
		tab = 
			tabName: 		tabName
			defaultHtml:	defaultHtml
			order:			order
		@tabData.push(tab)
		return tab

	## ---------------------------------------------------------------------------------------------------------------
	## Add all data of tabs sorted by "order" to the current instance
	##
	## @return [Array] : array of tab data sorted by "order"
	##
	addSortedTags: () =>
		sortedTags = @tabData.sort(@sorter)	
		@refreshTagOrders sortedTags
		for tag, index in sortedTags
			@addTab tag.tabName, tag.defaultHtml 
			console.log tag.tabName + ":" + tag.order
		return sortedTags	
	##-----------------------------------------------------------------------------------------------------------------
	## Refresh value of each Tag's order if there is duplicated one
	## @param [Array] : arrayToOrder array to be refreshed 
	## @return [Array] : array that is refreshed finally
	##
	refreshTagOrders: (arrayToOrder) =>
		if arrayToOrder[0].order < 0 then arrayToOrder[0].order = 0
		arrayToOrder.reduce (prevOrder, current) ->
			if prevOrder.order?
				prevOrder = prevOrder.order
			if current.order < 0
				console.log current.tabName + "," + prevOrder
				current.order = if prevOrder? then prevOrder + 1 else 0
			if prevOrder == current.order
				current.order++
			return current.order
		return arrayToOrder

	##-------------------------------------------------------------------------------------------------------------------	
	## function to be used to sort elements in array of tabs	
	## @param [Object] : object of tag that is to be ordered
	## @param [Object] : object of tag that is to be ordered
	## @return [Integer] : if first should be after second element, returned value will be 1, else -1 will be returned, and 0 means that there is no need to change those orders
	## 
	sorter: (a,b) ->
		## check if both of a and b are with 'order' param
		## if then normally compare to set their orders
		if a.order >= 0 and b.order >= 0
			if a.order > b.order
				return 1
			else if a.order < b.order
				return -1
			else
				return 1	
		## check if both a and b are without 'order' param
		## if then, no need to change their orders
		else if a.order == b.order
			return 0
		## if only a has not 'order' param, it will be after b
		else if a.order < 0
			return 1
		## if only b has not 'order' param, it will be after a
		else 
			return -1 


	onResize: (w, h)=>
		##|
		##|  Received resize event
		# console.log "DynamicTabs onResize w=#{w} h=#{h}"

	updateTabs: ()=>

		for id, tag of @tags

			if id == @activeTab
				tag.tab.addClass "active"
				tag.body.show()
				if tag.body.onResize?
					##|
					##|  Todo: check on this
					tag.body.onResize(-1, -1)

				setTimeout ()->
					w = $(window).width()
					h = $(window).height()
					globalTableEvents.emitEvent "resize", [w, h]
				, 10

			else
				tag.tab.removeClass "active"
				tag.body.hide()

			if tag.badge?
				tag.badgeText.html tag.badge
				tag.badgeText.show()
			else
				tag.badgeText.hide()

		true

	##|
	##|  Add a view to a tab
	##|  Return (resolves) with the tab
	##|  Calls callbackWithView with the new view
	##|  The promise is only complete after the callback completes.
	##|
	doAddViewTab : (viewName, tabText, callbackWithView) =>

		new Promise (resolve, reject) =>

			gid          = GlobalValueManager.NextGlobalID()
			content      = "<div id='tab_#{gid}' class='tab_content'></div>"
			tab          = @addTab tabText, content
			elViewHolder = $("#tab_#{gid}")
			doAppendView viewName, elViewHolder
			.then (view)=>

				view.elHolder = elViewHolder
				callbackWithView(view, tabText)
				resolve(tab)

	##|
	##|  Add a table to a tab which is a common function so 
	##|  we have included management for tabs with tables globally
	##|
	doAddTableTab : (tableName, tabText) =>

		new Promise (resolve, reject)=>

			@doAddViewTab "Table", tabText, (view, viewText)=>

				if !@tables? then @tables = {}
				table = view.loadTable tableName
				table.showCheckboxes = true
				table.setStatusBarEnabled()
				@tables[tableName] = table
				@tables[tableName].tab = @tabs[tabText]

				@tabs[tabText].table = table

			.then (tab)=>

				# total = @tabs[tabText].table.getTableTotalRows()
				# console.log "Setting Badge [#{tabText}] to #{total}:", @tabs[tabText].table
				# @tabs[tabText].setBadge(total)
				resolve(@tabs[tabText])

	onCheckTableUpdateRowcount: (tableName, newRowCount)=>

		if !@tables? then return
		console.log "onCheckTableUpdateRowcount table=#{tableName} new=#{newRowCount}"

		if @tables[tableName]?
			@tables[tableName].tab.badgeText.html newRowCount
			@tables[tableName].tab.badgeText.show()
			@tables[tableName].tab.badge = newRowCount

		true


