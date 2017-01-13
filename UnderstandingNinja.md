CoffeeNinja - Understanding Screens and Views
------------------------------------------

The server in this project is in *server*/NinjaServer.coffee and is very simple.

The overall concept used by the *Edge* system is based on:

- Screens : These are full definitions of a new screen the user will see.   Only one screen should be active at a time.

- Views: A view is a group of functions that can be put into any div and is similar to a GUI Widget in other languages.

Notes:

1. Each screen or view has 1, 2, or 3 files.  There is a .coffee file that is the code for that screen or view.  
2. There is a .pug file that is the optional HTML5 template
3. There is a .styl file that is the Stylus CSS template 

When a screen or view is requested, the server will compile the screen or view into a .js file and deliver it to the browser.   The Browser will then create an instance of the View or Screen class and add it to the display.

This method means that Screens and Views can be created by different developers easily.

There can be an unlimited number of screens and views but they are only loaded as needed.  Once loaded, the browser can easily re-use them for fast apps.

Views can be shown in many ways including in Tabs and Popup Windows.   Views are to be shared between many apps and as re-usable as possible.

Screens will eventually have Access Control Lists and other permissions to show who can access them.

See [screen_management.coffee](src/screen_manager/screen_management.coffee) for functions that load view and screen resources as needed.

Understanding the folders
------------------------------------------

| Folder            | Purpose
| ----------------- | ----------------------------------------------------------------
| ninja             | Common images and other files required by all Web Apps using CoffeeNinja
| vendor            | 3rd party Javascript used by CoffeeNinja
| views             | All common views designed to be available to any webapp using CoffeeNinja
| server            | The server for testing and building with CoffeeNinja
| src               | The source for CoffeeNinja
| test              | Test pages for CoffeeNinja

Everything in src/ is compiled into ninja/ninja.js and ninja/ninja.css as needed.   

Testing CoffeeNinja
------------------------------------------

Open a terminal and run 

    coffee NinjaServer.coffee 

Open a browser to 

    http://localhost:9000/

Each test case should have a title on the left side of the screen defined in [index.pug](test/template/index.pug) and a page defined in test/js/

The file [test_common.coffee](test/js/test_common.coffee) has some general functions to make each test page similar in design and style.
