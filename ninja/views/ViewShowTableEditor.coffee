class ViewShowTableEditor extends View

    getDependencyList: ()=>
        return [ "/ace/ace.js", "/ace/ext-language_tools.js" ]

    onSetupButtons: () =>

        ##|
        ##|  Toolbar button that allows a new column to be added
        ##|
        navButtonCreateNew = new NavButton "New Column", "toolbar-btn navbar-btn"
        navButtonCreateNew.onClick = (e)=>

            m = new ModalDialog
                showOnCreate: false
                content:      "Add a new field"
                position:     "top"
                title:        "New Field"
                ok:           "Save"

            m.getForm().addTextInput "name",   "Name"
            m.getForm().addTextInput "source", "Source"

            m.getForm().onSubmit = (form) =>

                data =
                    name     : form.name
                    source   : form.source

                DataMap.addColumn @editedTableKey, data
                DataMap.changeColumnAttribute @editedTableKey, form.source, "type", "text"
                DataMap.changeColumnAttribute @editedTableKey, form.source, "autoresize", true

                true

            m.show()

        # @addtoBoolbar [ navButtonCreateNew ]
        true

    onShowScreen: ()=>

    onResize: (pw, ph)=>
        # if !@elHolder? then return
        # if !@editorTable? or !@editorTable.rowDataRaw? then return
        # if @editorTable.rowDataRaw.length == 0 then return
        h = @elHolder.parent().parent().height()
        # w = @elHolder.width()
        @editorTable.elTableHolder.height h
        @editorTable.onResize()
        true

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor to create new tableEditor
    ##
    showTableEditor: (@editedTableKey) =>

        dm = DataMap.getDataMap()
        DataMap.removeTable "_editor"

        @rowsList = DataMap.getColumnsFromTable(@editedTableKey, null)
        @internalSetDataTypes()

        @editorTable = new TableView @elHolder.find(".viewTableHolder")
        # @editorTable = new TableView @elHolder.find(".windowbody")
        # @editorTable.elTableHolder.css "width", "100%"
        # @editorTable.elTableHolder.css "height", "400px"

        @editorTable.showConfigTable = false
        @editorTable.addTable "_editor"
        @editorTable.setFixedHeaderAndScrollable()

        @editorTable.addActionColumn
            width  : 50
            source : "delete",
            name   : "Delete"
            callback: (row)=>
                console.log "Delete on:", row

        @editorTable.moveActionColumn "order"
        @editorTable.sortByColumn("order")
        @editorTable.render()

        setTimeout @onResize, 500

        ##|
        ##|  Save callback from the data map
        DataMap.setSaveCallback "_editor", (id, field, oldValue, newValue)=>
            console.log @editedTableKey, "CHANGE id=#{id} field=#{field} newValue=#{newValue}"
            DataMap.changeColumnAttribute @editedTableKey, id, field, newValue
            true

        ##|
        ##|  Custom change event
        globalTableEvents.on "table_change", (tableName, source, field, newValue)=>

            console.log "Editor Custom #{tableName}/#{source}"

            if tableName == @editedTableKey
                path = "/_editor/#{source}/#{field}"
                console.log "Global....", path, newValue
                @editorTable.updateRowData()

    ## -------------------------------------------------------------------------------------------------------------
    ## function to get the created table instance
    ##
    ## @return [TableView] editorTable
    ##
    getTableInstance: ->
        return @editorTable

    ## -------------------------------------------------------------------------------------------------------------
    ## clears the html of the table used to remove the table
    ##
    clear: ->
        @tableHolder.html ""

    ## -------------------------------------------------------------------------------------------------------------
    ## internal function to sets the data type in the the datamap for the editor table
    ##
    internalSetDataTypes: () ->

        if !DataMap.getDataMap().types["_editor"]?

            ##| These data type will be same for all the table editor
            DataMap.setDataTypes "_editor", [
                    name     : "Name"
                    source   : "name"
                    visible  : true,
                    type     : "text"
                    editable : true
                    required : true
                    width    : 140
                ,
                    name     : "Source"
                    source   : "source"
                    visible  : true,
                    type     : "text"
                    editable : true
                    width    : 120
                ,
                    name     : "Visible"
                    source   : "visible"
                    visible  : true,
                    type     : "boolean"
                    editable : true
                    width    : 60
                ,
                    name     : "Ignored"
                    source   : "hideable"
                    visible  : true,
                    type     : "boolean"
                    editable : true
                    width    : 60
                ,
                    name     : "Editable"
                    source   : "editable"
                    visible  : true,
                    type     : "boolean"
                    editable : true
                    width    : 60
                ,
                    name     : "Required"
                    source   : "required"
                    visible  : true,
                    type     : "boolean"
                    editable : true
                    width    : 60
                ,
                    name     : "Autosize"
                    source   : "autosize"
                    visible  : true,
                    type     : "boolean"
                    editable : true
                    width    : 60
                ,
                    name     : "Align"
                    source   : "align"
                    visible  : true,
                    type     : "enum"
                    editable : true
                    required : false
                    width    : 90,
                    element  : "select",
                    options  : [ '', 'left', 'right', 'center' ]
                ,
                    name     : "Type"
                    source   : "type"
                    visible  : true,
                    type     : "enum"
                    editable : true
                    required : true
                    width    : 90,
                    element  : "select",
                    options  : Object.keys globalDataFormatter.formats
                ,
                    name     : "Width"
                    source   : "width"
                    visible  : true,
                    type     : "int"
                    editable : true
                    width    : 60
                ,
                    name     : "Options"
                    source   : "options"
                    visible  : true,
                    type     : "text"
                    editable : true
                    width    : 120
                ,
                    name     : "Formula/Code"
                    source   : "render"
                    visible  : true,
                    type     : "sourcecode"
                    editable : true
                    width    : 120
                    render:  (val)=>
                        if val? then return "Edit source"
                        return ""

            ]

        ##| add row data to dataMap about current column configurations
        for row in @rowsList
            DataMap.addData "_editor", row.getSource(), row.serialize()

        true
