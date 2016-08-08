## -------------------------------------------------------------------------------------------------------------
## class to create tab for tabs
##
class Tab

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	## @param [String] tabName the name of the tab
	## @param [String] defaultHtml the html to be displayed inside tab
	## @param [Integer] tabCount the count of current tab
	constructor: (@tabName, @defaultHtml, tabCount) ->
		@tabId = "tab#{tabCount}"
		@tabLink = $ "<a />",
			"data-toggle": "tab"
			href: "##{@tabId}"
			html: @tabName

		@listElement = $ "<li />",
			class: (tabCount == 0 ? "active": "")

		@content = $ "<div />",
			id: @tabId
			class: "tab-pane " + (tabCount == 0 ? "active")

		@listElement.append @tabLink
		@content.html @defaultHtml

		@tabLink.click ()->
			$(this).tab('show')


	## -------------------------------------------------------------------------------------------------------------
	## function to show tab
	##
	show: () ->
		@tabLink.tab('show')

	## -------------------------------------------------------------------------------------------------------------
	## function to set the badge on the tab
	##
	## @param [Integer] number the number to show inside badge
	## @param [String] type the type of badge can be success|danger|warning|primary
	## @param [String] direction the direction of the badge to display front or back
	##
	setBadge: (number, type = null, direction = 'front') ->
		badgeHtml = "<span class='badge #{if type then 'badge-'+type else ''} #{if direction isnt 'front' then 'badge-right'}'>#{number}</span>"
		@tabLink = $ "<a />",
			"data-toggle": "tab"
			href: "##{@tabId}"
			html: "#{if direction == 'front' then badgeHtml + @tabName else @tabName + badgeHtml}"
		@listElement.find("[href='##{@tabId}']").replaceWith(@tabLink)
		@tabLink.click ()->
			$(this).tab('show')


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
		@elHolder = $ "<div class='block' />"

		@tabList = $ "<ul />",
			"class": "nav nav-tabs"
			"data-toggle": "tabs"

		@tabContent = $ "<div />",
			"class": "ninja-tab-content tab-content"

		@elHolder.append @tabList
		@elHolder.append @tabContent
		$(holderElement).append @elHolder

		@tabCount = 0

	## -------------------------------------------------------------------------------------------------------------
	## Add a new tab to current instance
	##
	## @param [String] tabName the name of the tab to be adding
	## @param [String] defaultHtml optional html for the tab content
	## @return [Tab] the new tab Object which is created
	##
	addTab: (tabName, defaultHtml) =>
		tab = new Tab(tabName, defaultHtml, @tabCount)
		@tabList.append tab.listElement
		@tabContent.append tab.content
		if @tabCount == 0
			tab.show()

		@tabCount++

		return tab


		# <li class="active">
		#     <a href="#btabs-static-justified-home"><i class="fa fa-home"></i> Home</a>
		# </li>
		# <li>
		#     <a href="#btabs-static-justified-profile"><i class="fa fa-pencil"></i> Profile</a>
		# </li>
		# <li>
		#     <a href="#btabs-static-justified-settings"><i class="fa fa-cog"></i> Settings</a>
		# </li>


		# <div class="tab-pane active" id="btabs-static-justified-home">
		#     <h4 class="font-w300 push-15">Home Tab</h4>
		#     <p>...</p>
		# </div>
		# <div class="tab-pane" id="btabs-static-justified-profile">
		#     <h4 class="font-w300 push-15">Profile Tab</h4>
		#     <p>...</p>
		# </div>
		# <div class="tab-pane" id="btabs-static-justified-settings">
		#     <h4 class="font-w300 push-15">Settings Tab</h4>
		#     <p>...</p>
		# </div>
