## -------------------------------------------------------------------------------------------------------------
## class ModalMessageBox to show modal as message box
##
## @extends [ModalDialog]
##
class ModalSortItems extends ModalDialog

    # @property [String] content the content of the modal
    content:      "Sort Items"

    # @property [String] title the title of the modal
    title:        "Sort Items"

    # @property [String] ok text of the button1
    ok:           "Save"

    # @property [String] close text of the button2
    close:        "Close"

    # @property [Boolean] showFooter to show footer or not
    showFooter:   true

    # @property [Boolean] showOnCreate
    showOnCreate: false

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] message the message to show in the modal as message
    ##
    constructor: (message, list) ->

        ##|
        ##|  List is an array
        ##|  with each element has name, order, active
        ##|

        super()

        GlobalClassTools.addEventManager(this)

        @content = '''
            <div class='row sortingList'>
                <div class='col-sm-6'>
                    <ul id='sortItemsListLeft'>
                        <li class='header'> Visible Columns </li>
                    </ul>
                </div>
                <div class='col-sm-6'>
                    <ul id='sortItemsListRight'>
                        <li class='header'> Hidden Columns </li>
                    </ul>
                </div>
            </div>
        '''

        @show()

        @sortItemsListLeft = $("#sortItemsListLeft")
        @sortItemsListRight = $("#sortItemsListRight")

        @ItemList = {}

        for item in list
            @ItemList[item.name] = item.order
            if item.active? and item.active
                @sortItemsListLeft.append("<li data-name='#{item.id}'> #{item.title} - #{item.order} </li>")
            else
                @sortItemsListRight.append("<li data-name='#{item.id}'> #{item.title} - #{item.order} </li>")

        sortable "#sortItemsListLeft, #sortItemsListRight",
            items:                ':not(.header)'
            connectWith:          'connected'
            forcePlaceholderSize: true
            placeholderClass:     'placeholder'

        sortable('#sortItemsListLeft')[0].addEventListener 'sortupdate', (e)=>
            console.log "SORT UPDATE:", e.detail

        @onButton1 = (e)=>
            @hide()
            true

        @onButton2 = ()=>
            ##|
            ##|  Save
            @listActive = []
            @listInactive = []

            for e in @sortItemsListLeft.children()
                name = $(e).data("name")
                if !name? then continue
                @listActive.push(name)

            for e in @sortItemsListRight.children()
                name = $(e).data("name")
                if !name? then continue
                @listInactive.push(name)

            @hide()
            @emitEvent "save", [ @listActive, @listInactive ]
            true

