$ ->

    addTestButton "Simple Navbar", "Open", ()->
        addHolder('renderTest1')
        navBar = new DynamicNav("#renderTest1")
        navBar.render();

    addTestButton "Simple Navbar with button", "Open", ()->
        addHolder('renderTest1')
        navBar = new DynamicNav("#renderTest1")
        navButton = new NavButton "Test","btn btn-success navbar-btn",
            "data-click": "sampleAttribute"
        navBar.addElement(navButton)
        navBar.render();

    addTestButton "Simple Navbar with form", "Open", ()->
        addHolder('renderTest1')
        navBar = new DynamicNav("#renderTest1")

        ## populate form first arg is action of form, second arg is alignment left or right
        navForm = new NavForm "#","left" # align second arg can be right also
        navForm.addElement new NavInput("username",null,placeholder:"Username") # default type will text to set radio or checkbox use 3rd argument attributes
        navForm.addElement new NavInput('password', null,
            placeholder: 'Password'
            type: 'password')
        navForm.addElement new NavButton("Login", "navbar-btn btn-success btn")

        ## add populated form to navbar
        navBar.addElement(navForm)
        navBar.render();

    addTestButton "Simple Navbar with form and dropdown", "Open", ()->
        addHolder('renderTest1')
        $("#renderTest1").css height:'200px'
        navBar = new DynamicNav("#renderTest1")

        ## populate dropdown
        dd = new NavDropDown("Brian P.","right") # constructor arg is title and alignment left|right
        dd.addItem
            type:"link"
            text:"Action"
            callback: (e) ->
                console.log e
                alert "Action is clicked"
        dd.addItem({type: "divider"}) # by setting type to divider it will add divider
        dd.addItem
            type:'link'
            text:"Sample"
            callback: (e) ->
                console.log e
                alert "sample is clicked"

        ## add populate dropdown to navbar
        navBar.addElement(dd)
        navBar.render();

    addTestButton "Navbar with tabs", "Open", ()->
        addHolder('renderTest1')
        #add test tabs with ids
        $("#renderTest1").append("<div id='allTabs'></div>");
        tab1 = $ "<div />",
            class: 'tab-pane'
            id: "tab1"
        $("#allTabs").css({height:'200px'}).addClass("tab-content").append tab1
        tab2 = $ "<div />",
            class: "tab-pane"
            id: "tab2"
        $("#allTabs").append(tab2)
        $('#tab1').html("inside tab with id tab1")
        $('#tab2').html("inside tab with id tab2")
        ## tabs created

        ## create navbar for switching tabs
        navBar = new DynamicNav("#renderTest1")
        ## populate tabs
        tabs = new NavTabs('left') # alignment can be left|right
        tabs.addTabLink({text:"Tab 1",link:"#tab1"})
        tabs.addTabLink({text:"Tab 2",link:"#tab2"})
        ## add populated tabs to navbar
        navBar.addElement(tabs)
        navBar.render();

    go()
