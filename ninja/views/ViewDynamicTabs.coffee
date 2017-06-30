tabHeight = 32

class ViewDynamicTabs extends View

    ##|
    ##| setSize (see NinjaContainer) is called when the holder wants this dynamic tabs
    ##| to take up exactly some amount of space.  By default it will resize the tabs and
    ##| then onResize is called once the size has actually changed
    ##|
    # setSize: (w, h)=>

    onResize: (w, h)=>
        super(w, h)

        ##|
        ##|  Update the visible tab
        @updateTabs()

        true

    ##|
    ##|  total the badge values from all children
    getBadgeText: ()=>

        total = 0
        for id, tag of @tags
            if tag.body? and tag.body.getBadgeText?
                num = tag.body.getBadgeText()
                if typeof num != "number" then num = parseInt(num)
                total += num

        if total > 0 then return total
        return null

    ## -------------------------------------------------------------------------------------------------------------
    ## Add a new tab data to array named "tabData"
    ##
    ## @param [String] tabName the name of the tab to be adding
    ## @param [String] defaultHtml optional html for the tab content
    ## @param [Integer] order (optional) order of the tab that should >= 0, if not specified, set it to -1
    ## @return [Tab] the new tab Object which is created
    ##
    addTabData: (tabName, defaultHtml, order) =>
        if !order? then order = -1
        tab = {
            tabName,
            defaultHtml,
            order
        }
        @tabData.push tab
        return tab

    updateTabs: ()=>

        for id, tag of @tags

            if id == @activeTab
                tag.tab.addClass "active"
                tag.body.show()

                # console.log "Showing tab with ", tag.body, @getInsideWidth(), @getInsideHeight()

                if @getInsideHeight() == 0
                    tag.body.hide()
                else if tag.body.move?
                    tag.body.show()
                    tag.body.move 0, @height()-@getInsideHeight(), @getInsideWidth(), @getInsideHeight()

            else
                tag.tab.removeClass "active"
                tag.body.hide()

        @updateBadges()
        true

    updateBadges: ()=>

        for id, tag of @tags

            baseText = tag.badge
            if !baseText? and tag.body? and tag.body.getBadgeText?
                baseText = tag.body.getBadgeText()

            if baseText? and (typeof(baseText)=="number" or baseText.length > 0)
                tag.badgeText.html baseText
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
    doAddViewTab : (viewName, tabText, callbackWithView, sortOrder) =>

        new Promise (resolve, reject) =>

            gid = GlobalValueManager.NextGlobalID()
            tab = @addTab tabText, null, sortOrder
            tab.body.setView viewName, callbackWithView
            .then (view)=>
                view.elHolder = tab.body.el
                resolve(view)

            true

    ##|
    ##|  Add a table to a tab which is a common function so
    ##|  we have included management for tabs with tables globally
    ##|
    doAddTableTab : (tableName, tabText, sortOrder = null, callbackWithTableView) =>

        new Promise (resolve, reject)=>

            @doAddViewTab "Table", tabText, (view, viewText)=>

                if !@tables? then @tables = {}
                table = view.loadTable tableName
                table.showCheckboxes = true
                @tables[tableName] = table
                @tables[tableName].tab = @tabs[tabText]
                @tabs[tabText].table = table

                if callbackWithTableView?
                    callbackWithTableView(view)

                return true
            , sortOrder

            .then (tab)=>

                # total = @tabs[tabText].table.getTableTotalRows()
                # console.log "Setting Badge [#{tabText}] to #{total}:", @tabs[tabText].table
                # @tabs[tabText].setBadge(total)
                resolve(@tabs[tabText])

    onCheckTableUpdateRowcount: (tableName, newRowCount)=>

        if !@tables? then return
        # console.log "onCheckTableUpdateRowcount table=#{tableName} new=#{newRowCount}"

        if @tables[tableName]?
            @tables[tableName].tab.badgeText.html newRowCount
            @tables[tableName].tab.badgeText.show()
            @tables[tableName].tab.badge = newRowCount

        true

    ## -------------------------------------------------------------------------------------------------------------
    ## Add a new tab to current instance
    ##
    ## @param [String] tabName the name of the tab to be adding
    ## @param [String] defaultHtml optional html for the tab content
    ## @return [Tab] the new tab Object which is created
    ##
    addTab: (tabName, defaultHtml, sortOrder = null) =>

        ##|
        ##|  Return existing tab
        if @tabs[tabName]? then return @tabs[tabName]

        ##|
        ##|  Default sort order puts the tab at the end
        if !sortOrder? or typeof sortOrder != "number"
            sortOrder = Object.keys(@tags).length

        ##|
        ##|  Find where to insert
        insertPosition = 0
        for child in @tabList.getChildren()
            if sortOrder > child.sortOrder then insertPosition++

        id = "tab#{@tabCount++}"
        elTab = @tabList.addAtPosition "li", "ninja-nav-tab", insertPosition
        elTab.sortOrder = sortOrder
        elTab.setDataPath id
        elTab.on "click", @onClickTab

        elTabText = elTab.add "div", "ninja-tab-text"
        elTabText.html tabName

        elTabBadge = elTab.addDiv "ninja-badge"

        elBody = @tabContent.add "div", "ninja-nav-body"
        if defaultHtml?		
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

    onSetBadge: (num, classname)->
        id = this.id
        @parent.tags[id].badge = num

        if classname?
            @parent.tags[id].badgeText.addClass("badge-" + classname)

        return @parent.updateBadges()

    onClickTab: (e)=>
        # console.log "DynamicTabs onClickTab"
        if e? and e.path? then @show(e.path)
        return true

    getActiveTab: ()=>
        return @tags[@activeTab]

    show: (id)=>
        if !id? then return false
        if typeof id == "object" and id.id? then id = id.id
        if @tags[id]?
            @emitEvent "showtab", [ id, @tags[id] ]
            @activeTab = id
            @updateTabs()

        return true

    getTab: (tabName) =>

        ##|
        ##|  Return existing tab
        if @tabs[tabName]? then return @tabs[tabName]
        return null

    ##|
    ##|  Returns the size of the space available for the tab content
    getInsideHeight: ()=>
        h = @height()
        h -= (tabHeight+1)
        return h

    ##|
    ##|  Returns the size of the space available width
    getInsideWidth: ()=>
        return @getWidth()

    onShowScreen: ()=>

        @tags       = {}
        @tabs       = {}
        @tabCount   = 0
        @activeTab  = null

        @el.addClass "ninja-tabs"
        @tabList    = @add "ul", "ninja-tab-list", "ninja-tab-list"
        @tabList.height(tabHeight)

        @addDiv "clr"
        @tabContent = @add "div", "ninja-tab-content tab-content"
        @tabData  	= []

        ##|
        ##|  Allow this view to have events
        GlobalClassTools.addEventManager(this)

        ##|
        ##|  If someone updates the number for the badge, referesh the tabs
        globalTableEvents.on "row_count", ()=>
            @updateBadges()

        true