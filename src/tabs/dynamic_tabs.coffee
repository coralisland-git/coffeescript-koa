
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

		$(holderElement).append @elHolder.el

		globalTableEvents.on "row_count", @onCheckTableUpdateRowcount

	onSetBadge: (num, classname)->
		id = this.id
		# console.log "onSetBadge num=#{num} classname=#{classname}", id, this.parent
		@parent.tags[id].badge = num
		@parent.tags[id].badgeText.addClass classname
		@parent.updateTabs()

	onClickTab: (e)=>
		if e? and e.path? then @show(e.path)
		return true

	show: (id)=>
		if !id? then return false
		if typeof id == "object" and id.id? then id = id.id
		if @tags[id]?
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

	updateTabs: ()=>

		for id, tag of @tags

			if id == @activeTab
				tag.tab.addClass "active"
				tag.body.show()
				if tag.body.onResize?
					tag.body.onResize()

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
	##|  Add a table to a tab which is a common function so we
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

		console.log "onCheckTableUpdateRowcount table=#{tableName} new=#{newRowCount}"
		if @tables[tableName]?
			@tables[tableName].tab.badgeText.html newRowCount
			@tables[tableName].tab.badgeText.show()
			@tables[tableName].tab.badge = newRowCount

		true


