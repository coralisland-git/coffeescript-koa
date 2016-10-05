
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
		@tabCount   = 0
		@activeTab  = null
		@elHolder   = new WidgetTag("div", "ninja-tabs")
		@tabList    = @elHolder.add "ul", "ninja-tab-list"
		@elHolder.addDiv "clr"
		@tabContent = @elHolder.add "div", "ninja-tab-content tab-content"

		$(holderElement).append @elHolder.el

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

	## -------------------------------------------------------------------------------------------------------------
	## Add a new tab to current instance
	##
	## @param [String] tabName the name of the tab to be adding
	## @param [String] defaultHtml optional html for the tab content
	## @return [Tab] the new tab Object which is created
	##
	addTab: (tabName, defaultHtml) =>

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