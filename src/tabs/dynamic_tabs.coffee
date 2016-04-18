class DynamicTabs

    constructor :(holderElement)->

        @elHolder   = $ "<div class='block' />"

        @tabList    = $ "<ul />",
            "class"       : "nav nav-tabs"
            "data-toggle" : "tabs"

        @tabContent = $ "<div />",
            "class"       : "block-content tab-content"

        @elHolder.append @tabList
        @elHolder.append @tabContent
        $(holderElement).append @elHolder

        @tabCount = 0

    ##|
    ##| Add a tab
    ##| @param tabName [string] The name of the tab to be adding
    ##| @param defaultHtml [string] Optional html for the tab content
    ##| @return the element
    ##|
    addTab: (tabName, defaultHtml) =>

        tabid = "tab#{@tabCount}"

        tabLink = $ "<a />",
            "data-toggle" : "tab"
            href  : "##{tabid}"
            html  : tabName

        listElement = $ "<li />",
            class : (@tabCount == 0 ? "active" : "")

        content = $ "<div />",
            id    : tabid
            class : "tab-pane " + (@tabCount == 0 ? "active")

        listElement.append tabLink
        @tabList.append listElement
        @tabContent.append content
        content.html defaultHtml

        if @tabCount == 0
            tabLink.tab("show")

        tabLink.click ()->
            $(this).tab('show')

        @tabCount++

        return content


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
