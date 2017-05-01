DataSetConfig = require 'edgecommondatasetconfig'
dataFormatter   = new DataSetConfig.DataFormatter()

allTests = []

doEdit = (num, obj)=>

    console.log "Test=", allTests[num]

    existingValue = $(obj).text().trim()
    formatter = dataFormatter.getFormatter allTests[num][0]
    formatter.editData $(obj), existingValue, "/test/#{num}", (path, value) =>
        console.log "Saving", path, value
        $("#results").html "Saving path=#{path}, value=#{value} type=#{typeof value}"
        true

    true

    # parts     = path.split '/'
    # tableName = parts[1]
    # keyValue  = parts[2]
    # fieldName = parts[3]

    # existingValue = @engine.getFast tableName, keyValue, fieldName
    # formatter     = @types[tableName].col[fieldName].formatter

    # ##|
    # ##|  Fix the options in the global formatter object
    # if @types[tableName].col[fieldName].options?
    #     formatter.options = @types[tableName].col[fieldName].options

    # formatter.editData el, existingValue, path, @updatePathValueEvent

$ ->

    $("head").append $ '''
    <style type="text/css">
    .testEditorTypes {
        width: 1000px;
    }
    .testEditorTypes td
    {
        padding: 4px;
        border: 1px solid #bbbbbb;
        max-width: 300px;
        overflow-wrap: break-word; 
    }
    .testEditorTypes th
    {
        padding: 4px;
        font-weight: 600;
        border-bottom: 1px solid #909090;
    }
    #results {
        padding-top: 20px;
        font-size: 14px;
    }
    .scrollcontent {
        height: 100%;
    }
    </style>
    '''

    html = "<table class='testEditorTypes'>"
    html += "<tr><th> Format </th><th> Comment </th> <th width='220'> Test Value </th> <th width='220'> Format Value </th> <th width='220'> Unformat Value </th></tr>"

    addExample = (format, value, comment, options) ->

        fValue = dataFormatter.formatData format, value, options, null
        uValue = dataFormatter.unformatData format, value, options, null

        num = allTests.length
        allTests.push [format, value, options]

        click = "class='editable dt_#{format}' onClick='doEdit(#{num}, this);' "
        html += "<tr><td> #{format} </td><td> #{comment} </td><td #{click}> #{value} </td> <td> #{fValue} </td><td> #{uValue} </td></tr>"

    addExample "text"         , "Test string value", "Simple Text"
    addExample "int"          , 10, "Simple Int"
    addExample "int"          , 10.05, "Float cast to int"
    addExample "number"       , 50, "Simple Int as Number"
    addExample "number"       , 50.50, "Float as Number"

    addExample "int"       , null, "Empty Value"
    addExample "int"       , "", "Empty Value"

    addExample "number"       , "150.0005", "Text Float as Number"
    addExample "decimal"      , 100.12, "Simple Decimal"
    addExample "decimal"      , 100.1234, "Simple Decimal, 4 digits"
    addExample "money"        , 15.678, "Simple Money"
    addExample "money"        , "$2,335.67", "Formatted money"
    addExample "date"         , new Date(), "Simple date as Date"
    addExample "date"         , "2016-05-15", "Simple date text as Date"
    addExample "datetime"     , new Date(), "Simple date time"
    addExample "age"          , "2016-06-01 12:16:05", "Date as text"
    addExample "age"          , new Date("2016-06-01 12:16:05"), "Date as object"
    addExample "enum"         , "Apple,Grape,Orange", "Enum as text"
    addExample "enum"         , ["Apple","Grape","Orange"], "Enum as array"
    # addExample "distance"     ,
    addExample "boolean"      , true, "Boolean true"
    addExample "boolean"      , 1, "Boolean true"
    addExample "boolean"      , "Yes", "Boolean true"
    addExample "percent"      , 0.1, "Percent as decimal"
    addExample "percent"      , "52%", "Percent as text"
    addExample "timeago"      , new Date("2016-06-01 12:16:05"), "Date as object"
    addExample "sourcecode"   , "var name='Brian';"
    addExample "tags"         , "Apple,Grape,Orange", "Tags as text"
    addExample "tags"         , ["Apple","Grape","Orange"], "Tags as array"
    addExample "multiselect"  , "Apple,Grape,Orange", "multiselect as text", ['Apple', 'Grape', 'Orange', 'Banana']
    addExample "multiselect"  , ["Apple","Grape"], "multiselect as array", ['Apple', 'Grape', 'Orange', 'Banana']
    addExample "memo"         , 'This is a test\nHaving two lines"', "Popup Editor"
    addExample "imagelist"    , "./js/test_Data/images/1.jpg, ./js/test_Data/images/2.jpg, ./js/test_Data/images/3.jpg, ./js/test_Data/images/4.jpg, ./js/test_Data/images/5.jpg, ./js/test_Data/images/6.jpg, ./js/test_Data/images/7.jpg", "Imagelist as 'string'", null
    addExample "imagelist"    , ["./js/test_Data/images/fake.jpg","./js/test_Data/images/2.jpg","./js/test_Data/images/3.jpg","./js/test_Data/images/4.jpg","./js/test_Data/images/5.jpg","./js/test_Data/images/6.jpg","./js/test_Data/images/7.jpg"], "Imagelist as 'Array'", null

    html += "</table>"
    html += "<div id='results'>Click a cell in the Test Value column.</div>"


    # html += "<p><textarea id='edit123' style='width:600px; height: 400px;'></textarea>"

    addHolder "editors"
    $("#editors").html html


    # $("#edit123").trumbowyg()
