class ViewShowTableEditor extends View

    getDependencyList: ()=>
        return [ "/ace/ace.js", "/ace/ext-language_tools.js" ]

    setupNavbar: ()=>

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

                if !form.source? or form.source.length == 0
                    form.source = form.name.replace(" ", "_").replace(/[^a-zA-Z0-9]/g, "_").toLowerCase()

                data =
                    name       : form.name
                    source     : form.source
                    visible    : true
                    editable   : true
                    type       : "text"
                    "autosize" : true

                DataMap.addColumn @editedTableKey, data
                DataMap.changeColumnAttribute @editedTableKey, form.source, "type", "text"
                DataMap.changeColumnAttribute @editedTableKey, form.source, "autosize", true
                @updateData()
                m.hide()

                true

            m.show()

        @viewNavbar.addToolbar [ navButtonCreateNew ]
        true

    updateData: ()=>
        @rowsList = DataMap.getColumnsFromTable(@editedTableKey, null)
        @internalSetDataTypes()
        true

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor to create new tableEditor
    ##
    showTableEditor: (@editedTableKey) =>

        dm = DataMap.getDataMap()
        DataMap.removeTable "_editor"

        @rowsList = DataMap.getColumnsFromTable(@editedTableKey, null)
        @internalSetDataTypes()

        console.log "Setting doSetViewWithNav"
        @doSetViewWithNavbar "Table", (@viewTable, @viewNavbar)=>

            @editorTable = @viewTable.addTable "_editor"
            @editorTable.showConfigTable = false
            @editorTable.showFilters = false
            @editorTable.setAutoFillWidth()

            @editorTable.addActionColumn
                width  : 80
                source : "delete",
                name   : "Delete"
                callback: (row)=>
                    console.log "Delete on:", row

            @editorTable.addSortRule("order", 1)

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

            @setupNavbar()

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

        DataMap.removeTable("_editor")

        ##| These data type will be same for all the table editor
        DataMap.setDataTypes "_editor", [
                name:     ""
                source:   "order"
                visible:  true
                type:     "text"
                width:    36
                editable: false
                autosize: false
                render: (val)->
                    #return "<i class='dragHandle fa fa-list-ul '></i> #{val}"
                    return "#{val}"
            ,
                name     : "Name"
                source   : "name"
                visible  : true,
                type     : "text"
                editable : true
                required : true
                width    : 140
                autosize : true
            ,
                name     : "Source"
                source   : "source"
                visible  : true,
                type     : "text"
                editable : true
                width    : 120
                autosize : true
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
                name     : "Calculation"
                source   : "calculation"
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
                autosize : true
            ,
                name     : "Text Color"
                source   : "cellColor"
                visible  : true,
                type     : "sourcecode"
                editable : true
                width    : 60
                render:  (val)=>
                    if val? then return "Edit source"
                    return ""
            ,
                name     : "Formula/Code"
                source   : "render"
                visible  : true,
                type     : "sourcecode"
                editable : true
                width    : 120
                autosize : true
                calculation: false
                render:  (val)=>
                    if val? then return "Edit source"
                    return ""

        ]

        ##| add row data to dataMap about current column configurations
        for row in @rowsList
            DataMap.addData "_editor", row.getSource(), row.serialize()

        true
