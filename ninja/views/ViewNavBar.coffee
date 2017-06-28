class ViewNavBar extends View

    onShowScreen: ()=>
        @toolbarHeight = 50
        @toolbar = new DynamicNav(@el)

    getMinHeight: ()=>
        return @toolbarHeight

    getMaxHeight: ()=>
        return @toolbarHeight

    ##|
    ##|  Add a toolbar
    ##|
    addToolbar: (buttonList) =>

        for button in buttonList
            @toolbar.addElement button

        @toolbar.render()
        true