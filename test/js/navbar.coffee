$ ->

    addTestButton "Simple Navbar", "Open", ()->
        div = addHolder().el
        navBar = new DynamicNav(div)
        navBar.render();

    addTestButton "Simple Navbar with button", "Open", ()->
        navBar = new DynamicNav(addHolder().el)
        navButton = new NavButton "Test","btn btn-success navbar-btn",
            "data-click": "sampleAttribute"
        navBar.addElement(navButton)
        navBar.render();

    addTestButton "Simple Navbar with form", "Open", ()->
        navBar = new DynamicNav(addHolder().el)

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
        navBar = new DynamicNav(addHolder().el)

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

    go()
