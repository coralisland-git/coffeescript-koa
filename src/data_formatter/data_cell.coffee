##|
##|  A data cell is any html tag that contains data
##|  Where that data is mapped to a specific
##|  piece of information and contains some known type to be formatted
##|
##|  The data is mapped as such:
##|  /Base Path/Table or Data Type/Reference ID/Field Name
##|  For example /Property/123/Address or /GeoData/Zipcodes/28117/Country
##|

root = exports ? this
class DataCell

    ##|
    ##|  Path on the server that is attached to this div
    editorDataPath      : null

    ##|
    ##|  Unique ID for this div
    gid                 : null

    ##|
    ##|  Default width
    width               : null

    ##|
    ##|  System update path
    basePath            : null

    ##|
    ##|  True if the tag can be dynamically edited
    editable            : null

    tagType             : "div"

    elHolder            : null
    formatter           : null

    isEditable: () =>
        if typeof @editable == "undefined" or @editable == null or @editable == false
            return false
        return true

    initFormat: (formatType, formatOptions) =>

        @formatter = new DataFormatter(formatType, formatOptions)
        @width     = @formatter.width
        return @formatter

    ##|
    ##|  The base path is used to output an update tag for the column
    setBasePath: (@basePath) =>

    constructor: (@elHolder) ->

    ##|
    ##|  Verify that elHolder is setup correctly
    checkHolderElement: () =>
        # @elHolder = $("[data-path='" + @editorDataPath + "']")

    recordChange: (field, value) =>
        @checkHolderElement()
        console.log "Record Change, Field=#{field}, Value=#{value} DataPath=#{@editorDataPath} GID=#{@gid}"

        if @objReference != null
            @objReference[field] = value

        if @formatter == null
            @elHolder.html value
        else
            @elHolder.html @formatter.displayFormat(value, @objReference)

        ##|
        ##|  Tell the server
        if @editorDataPath != null
            api.UpdateByPath @editorDataPath, value

    ##|
    ##|  Get HTML for this tag
    Render: (counter, obj) =>
        if @visible == false then return ""

        otherClasses = ""
        otherProps = ""

        if @isEditable()
            otherClasses += " editable"
            otherProps += " f='#{@name}'"

        if typeof obj.rowOptionClass != "undefined"
            otherClasses += " #{obj.rowOptionClass}"

        if typeof @basePath != "undefined" && @basePath != 0
            otherProps += " data-path='#{@basePath}/#{@name}' "
            otherProps += " data-type='#{@formatter.getDataType()}' "

        @gid = GlobalValueManager.NextGlobalID()
        html = "<#{@tagType} id='c#{@gid}' class='col_#{@name}#{otherClasses}'"

        if @formatter.styleFormat != null and @formatter.styleFormat.length > 0
            html += " style='#{@formatter.styleFormat}'"

        html += " #{otherProps}>";
        html += @formatter.displayFormat(obj[@name], obj)
        html += "</#{@tagType}>";

    updateValue: (value, @objReference) =>

        @checkHolderElement()
        html = @formatter.displayFormat(value, @objReference)
        # console.log "html=", html, " for value=", value
        $("[data-path='" + @editorDataPath + "']").html html
        # console.log "$(\"[data-path='" + @editorDataPath + "']\") = 'xx'"
        # @elHolder.html html


    ##|
    ##|  Show the editor for this column
    showEditor: (x, y, @objReference, dataPath, @elHolder) =>

        @checkHolderElement()
        @editorDataPath = dataPath

        @objReference[@name] = $($("[data-path='" + @editorDataPath + "']")[0]).text()

        console.log "ShowEditor (#{x}, #{y}), dataPath=#{dataPath}, type=#{@formatter.type} obj=", @objReference, " [", @formatter.options, "]"

        if @formatter.type == "boolean"

            p = new PopupMenu "Options", x, y
            p.addItem "Yes", (coords, data) =>
                @recordChange @name, 1
            p.addItem "No", (coords, data) =>
                @recordChange @name, 0

        else if @formatter.type == "enum"
            ##|
            ##|  Show a popup menu
            if typeof @options == "undefined" or @options == null
                @options = @formatter.options

            p = new PopupMenu "Options", x, y
            console.log "OP=", @options, "type=", typeof @options, @options.length
            if typeof @options == "object" and typeof @options.length == "number"
                for i, o of @options
                    p.addItem o, (coords, data) =>
                        @recordChange @name, data
                    , o
            else
                for i, o of @options
                    p.addItem o, (coords, data) =>
                        @recordChange @name, data
                    , i

        else if @formatter.type == "datetime"

            @picker = new PopupMenuCalendar @objReference[@name], x - 175, y - 20
            @picker.onChange = (newValue) =>
                @recordChange @name, newValue
        else

            oldHtml = @elHolder.html()
            @elHolder.html ""

            console.log "Value=", @objReference[@name], " name=", @name

            d = new DynamicEdit @elHolder,
                path  : @editorDataPath,
                format: @formatter
                value : @objReference[@name]

                onSave: (newVal, theEditor) =>
                    console.log "DYNAMIC SAVE, PATH=", @path, " or ", @editorDataPath, " = ", newVal
                    @recordChange @name, newVal
                    theEditor.close()

                onClose: () =>
                    console.log "value on close=", @objReference[@name], " === ", @formatter.displayFormat(@objReference[@name], @objReference)
                    $("[data-path='" + @editorDataPath + "']").html @formatter.displayFormat(@objReference[@name], @objReference)
                    $(".editing").removeClass "editing"

            d.elEdit.focus()
            d.elEdit.select()
            console.log "Unknown type for dynamic edit:", @formatter.type

