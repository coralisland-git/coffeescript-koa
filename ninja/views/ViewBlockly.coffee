##|

class BlocklyCodeBlock

    constructor: (@type, @x) ->

        @y      = null
        @fields = {}

        if !@x? or @x == 0
            @x = 300

        ##|
        ##|  This is a Blockly block - input the XML into the Javascript code block
        ##|  helper class, currently imports x, y, and fields
        ##|
        if @type? and typeof @type == "object" and @type.init? and @type.id?

            @block = @type
            @x     = @block.xy_.x
            @y     = @block.xy_.y

            ##|
            ##|  Possible inputs
            for inp in @block.inputList
                for row in inp.fieldRow
                    ##|
                    ##|  Example for a variable, name='VAR', text='City Name', value='City Name'
                    name = row.name
                    text = row.text_
                    value = row.value_
                    @fields[name] = value

            @type = @block.type

    addField: (name, value) =>
        @fields[name] = value
        return this

    addMutation: (name, value)=>
        if !@mutations?
            @mutations = {}

        @mutations[name] = value;
        return this;

    addChild: (valueName, childBlock) =>

        if !@children?
            @children = {}

        if !@children[valueName]?
            @children[valueName] = []

        @children[valueName].push childBlock
        childBlock.parentBlock = this
        return this

    addStatement: (valueName, childBlock) =>

        if !@statement?
            @statement = {}

        if !@statement[valueName]?
            @statement[valueName] = []

        @statement[valueName].push childBlock
        childBlock.parentBlock = this
        return this

    ##|
    ##| Set the next node and return that node for chaining
    setNextNode: (newNode) =>
        @nextNode = newNode
        return newNode

    getYValue: ()=>

        if @y? and @y > 0 then return @y
        if @parentBlock? then return 0

        if !globalYValues[@type]
            globalYValues[@type] = 40

        y = globalYValues[@type]
        globalYValues[@type] += 30
        return y

    ##|
    ##|  Return Blockly XML from this block
    ##|
    getXml: (flags)=>

        if @parentBlock? and (not flags? or flags != "child")
            ##|
            ##|  If this block is the chld of another, don't add xml for it.
            return ""

        y = @getYValue()

        xml = ""
        xml += "<block type='#{@type}' x='#{@x}' y='#{y}'>"

        if @mutations?
            for keyName, keyVal of @mutations
                xml += "<mutation #{keyName}='#{keyVal}'></mutation>"

        for keyName, keyVal of @fields
            xml += "<field name='#{keyName}'>#{keyVal}</field>"

        if @children?

            for valueName, childrenList of @children

                for child in childrenList
                    xml += "<value name='#{valueName}'>"
                    xml += child.getXml("child")
                    xml += "</value>"

        if @statement?

            for valueName, childrenList of @statement

                for child in childrenList
                    xml += "<statement name='#{valueName}'>"
                    xml += child.getXml("child")
                    xml += "</statement>"

        if @nextNode?
            xml += "<next>"
            xml += @nextNode.getXml("child")
            xml += "</next>"

        xml += "</block>"
        return xml



class ViewBlockly extends View

    getDependencyList: ()=>
        return [ "/vendor/blockly/blockly_compressed.js", "/vendor/blockly/javascript_compressed.js", "/vendor/blockly/blocks_compressed.js", "/vendor/blockly/en.js" ]


    ##|
    ##| Nothing extra, you can over-write and add your own html
    onBeforeShowSamples: (variableName)=>
        return ""

    ##|
    ##|  Event called when workspace text changes
    onSaveWorkspace: (xmlText)=>
        true

    ##|
    ##|  Event called when the initial blocks are to be loaded after blockly is setup
    onLoadInitialBlocks: ()=>
        true


    ##|
    ##|  Called when the "ignore variable" diaglog closes and a new variable
    ##|  is to be ignored.   Remove it from the page and redraw
    onIgnoreVariable: (name, e) =>
        @ignoreList.push name
        @regroupItems()
        true

    ##|
    ##| Initialize all view variables, called when view is created.
    onShowScreen: ()=>
        console.log "ViewBlockly onShowScreen"

        @blocks                 = []
        @knownBlocks            = {}
        @knownVariablesGet      = {}
        @knownVariablesSet      = {}
        @sampleData             = []
        @ignoreList             = []
        @toolboxWidth           = 160
        @toolboxFlyoutWidth     = 400
        @blocklyZindex          = 4000
        @blocklyMaxScrollHeight = 5000

        @divToolbox = null          ##|  Div holder for the blockly toolbox
        @workspace = null           ##|  Blockly workspace

        @options =
            script_name   : "blocky_script"
            padding_left  : 0
            padding_right : 0
            padding_top   : 0
            padding_bottom: 0

        ##|
        ##| Prevent inifinite loops
        window.LoopTrap = 1000
        Blockly.JavaScript.INFINITE_LOOP_TRAP = 'if(--window.LoopTrap == 0) throw "Infinite loop.";\n';

        ##|
        ##| Allow events within this view
        GlobalClassTools.addEventManager(this)

        ##|
        ##| Create the available toolbox items
        @buildToolbox()

        ##|
        ##|  Setup Blockly

        @workspace = Blockly.inject @element,
            toolbox: @divToolbox[0]
            grid:
                spacing: 20
                length: 3
                snap: true
                colour: '#ccc'
            collapse: true
            comments: true

        @workspace.addChangeListener @onBlocklyEvent
        @onLoadInitialBlocks()

        @on "ShowSamples", @showSamples
        @on "CreateAssignment", @onShowAssignmentDialog
        @on "IgnoreVariable", @onIgnoreVariable

    ##|
    ##|  Assuming that BlocklyHelper has samples registered in @sampleData,
    ##|  This can be called to display a popup window with the sample
    ##|  for a given variable showing.
    ##|
    showSamples: (name, html) =>

        console.log "NAME=", name
        console.log "HTML=", html

        html = @onBeforeShowSamples(name)
        if !html? then html = ""

        html  = "<div class='blocklyShowSamples'>" + html
        html += "<div class='itemTitle'> <b>#{name}</b> Samples </div>"
        odd   = "odd"
        for sampleVal, sampleCount of @sampleData[name]
            if !sampleVal? or sampleVal.length < 1 then sampleVal = "[Empty]"
            sampleCount = numeral(sampleCount).format("#,###")
            html += "<div class='sampleText #{odd}'> #{sampleVal} <div class='pull-right text-right'> #{sampleCount} </div> </div>"
            if odd == "odd" then odd = "even" else odd = "odd"

        if !@divSamples?
            w      = $(window).width()
            h      = $(window).height()
            top    = $(window).scrollTop() + 10
            bottom = top + h - 20
            left   = w - 460
            right  = w - 10

            console.log "Show popup at x=#{left}, y=#{top} (w=#{w},h=#{h},r=#{right},b=#{bottom})"

            @divSamples = new PopupWindow("Samples", left, top, { w: right-left, h: bottom-top })

        html += "</div>"
        @divSamples.html html
        @divSamples.setBackgroundColor "#F8F6EB"
        @divSamples.open()
        true

    ##|
    ##|  Reset the list of variables to ignore
    setIgnore: (@ignoreList) =>
        console.log "Setting ignore: ", @ignoreList
        @regroupItems()
        @workspace.render()
        true

    ##|
    ##|  Layout the items again
    ##|  Takes a long time for some reason for Blockly to layout the XML
    regroupItems: ()=>
        window.globalBusyDialog.exec "Updating layout", ()=>
            @regroupItemsActual()

    ##|
    ##|  Default onSelect event looks for variables and calls showSamples
    ##|  Emits: "selected" with a CodeBlock
    ##|
    onSelected: (block)=>

        if block?
            codeBlock = new BlocklyCodeBlock(block)
            if block.type == "variables_get"
                @showSamples codeBlock.fields["VAR"]

            @emitEvent "selected", [codeBlock]
        else
            @emitEvent "selected", [null]

        true

    ##|
    ##|  Called by Blockly for an event
    onBlocklyEvent: (e)=>

        if e.type == Blockly.Events.MOVE #and (e.newParentId? or e.newInputName?)

            ##|
            ##| Block moved, possibly connected to another block
            return

        if e.type == Blockly.Events.CHANGE

            console.log "Change event: ", e.toJson()
            setTimeout @doSaveWorkspace, 10

        if e.type == Blockly.Events.UI

            if e.element == "selected"

                selectedBlock = @workspace.getBlockById e.newValue
                @onSelected selectedBlock

            return

        if e.type == Blockly.Events.CREATE

            ##|
            ##|  Block has been created
            ##|  e.ids = array of new block ids
            ##|  e.xml = new XML

            return

        true

    ##|
    ##|  Restore the workspace with given XML
    setXmlText: (xmlText) =>

        @workspace.clear();
        xmlDom = Blockly.Xml.textToDom xmlText

        custom = xmlDom.getElementsByTagName("custom")[0];
        if custom? and custom
            scrollX = parseInt(custom.getAttribute("scrollx"))
            scrollY = parseInt(custom.getAttribute("scrolly"))
            console.log "RESTORING SCROLL: #{scrollX} x #{scrollY}"
            if !isNaN(scrollX) then @workspace.scrollX = scrollX
            if !isNaN(scrollY) then @workspace.scrollY = scrollY
            @ignoreList = custom.getAttribute("ignore").split(",")
            console.log "RESTORING LIST:", @ignoreList

        Blockly.Xml.domToWorkspace xmlDom, @workspace

        true

    ##|
    ##|  Returns XML text to save this workspace
    getXmlText: ()=>

        xml     = Blockly.Xml.workspaceToDom @workspace

        ##|
        ##| Add the ignore list
        custom = $.parseXML("<custom />").firstChild
        custom.setAttribute("scrollx", @workspace.scrollX)
        custom.setAttribute("scrolly", @workspace.scrollY)
        custom.setAttribute("ignore", @ignoreList.join(","))
        xml.insertBefore(custom, xml.firstChild)

        ##|
        ##|  Return the text version
        xmlText = Blockly.Xml.domToText xml
        return xmlText

    ##|
    ##|  Display a popup with the XML Text
    showCurrentXML: ()=>

        Prism.languages.xml = Prism.languages.markup;

        content = "Current Blockly XML:<br><pre style='width: 860px; height: 600px;'><code class='language-xml'>"

        xmlText = @getXmlText()
        xmlText = CodeHighlighter.utilFormatXML xmlText
        xmlText = xmlText.replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;")

        content += xmlText
        content += "</code></pre>"

        m = new ModalMessageBox content
        Prism.highlightAll()
        true


    ##|
    ##|  Create custom tools for the toolbox
    ##|
    buildToolbox: ()=>

        # if window.globalToolboxCreated? and window.globalToolboxCreated
            # return

        getFieldList = ()=>

            options = []
            options.push ["City", "city"]
            options.push ["State", "state"]
            options.push ["Zipcode", "zip"]
            options

        for n in [0...1000]
            if Blockly.Css.CONTENT[n]?
                Blockly.Css.CONTENT[n] = Blockly.Css.CONTENT[n].replace ": 999;", ": 2999;"

        setupCustomBlockly.setupBlocks(Blockly, this)

        @divToolbox = $(@toolboxText())
        window.globalToolboxCreated = true
        $("body").append @divToolbox

        true


    ##|
    ##|  Automatically called when the view is created with optional data passed in
    setData: (@optionsData)=>
        console.log "Helper:", @options

    ##|
    ##|  Resize the view
    onResize: (w, h)=>
        super(w, h)
        console.log "Blockly view resize:", w, h

    regroupItemsActual: ()=>

        xml = Blockly.Xml.workspaceToDom @workspace
        elements = xml.getElementsByTagName("block")

        offset = @offset()
        top = 40 - (offset.top - 109)
        console.log "OFFSET=", offset, @workspace.scrollY

        globalYValues   = {}
        unassignedY     = top
        assignedY       = 40

        unassigned      = {}
        unassignedNames = []
        ignoredNames    = []


        ##|
        ##|  Convert ignore list to regex
        ignoreRegex = []
        for ignoreText in @ignoreList
            if ignoreText? and ignoreText.length > 1
                ignoreRegex.push new RegExp(ignoreText, "i")

        for block in elements

            found = false

            thisBlockType = block.getAttribute("type").toString()
            if thisBlockType == "variables_get"
                ##|
                ##|  This is a variable, see if it's already assigned
                nodeName = block.parentNode.nodeName.toString()
                if nodeName == "XML"
                    ##|
                    ##|  Unassigned variable

                    varName = block.children[0].innerText
                    skipped = false
                    for skipText in ignoreRegex
                        if skipText.test varName
                            skipped = true

                    if skipped
                        ignoredNames.push varName
                    else
                        unassignedNames.push varName

                    unassigned[varName] = block
                    found = true

            if not found
                nodeName = block.parentNode.nodeName.toString()
                if nodeName == "XML"
                    block.setAttribute("x", -40)
                    block.setAttribute("y", assignedY)
                    assignedY += 400
                    found = true

        ##|
        ##| Place variables
        console.log "ua=", unassignedY
        names = unassignedNames.sort()
        half  = Math.floor(names.length / 2) + 1
        count = 0
        xloc  = 700
        for name in names
            block = unassigned[name]
            block.setAttribute("x", xloc)
            block.setAttribute("y", unassignedY)
            unassignedY += 30

            if unassignedY + 80 > @blocklyMaxScrollHeight
                xloc = xloc + 360
                unassignedY = top

        ##|
        ##| Place ignore
        names = ignoredNames.sort()
        xloc  += 360 + 500
        unassignedY = 40
        for name in names
            block = unassigned[name]
            block.setAttribute("x", xloc)
            block.setAttribute("y", unassignedY)
            unassignedY += 30

            if unassignedY + 80 > @blocklyMaxScrollHeight
                xloc = xloc + 360
                unassignedY = top

        @workspace.clear();
        Blockly.Xml.domToWorkspace xml, @workspace
        true


    ##|
    ##|  Return a list of variables and if they are assigned
    doFindVariables: ()=>

        list = {}

        xml = Blockly.Xml.workspaceToDom @workspace
        elements = xml.getElementsByTagName("block")
        for block in elements
            thisBlockType = block.getAttribute("type").toString()
            if thisBlockType == "variables_get"
                varName = block.children[0].innerText
                parent  = block.parentNode
                nodeName = parent.nodeName.toString()
                if nodeName == "XML"
                    list[varName] =
                        xml: block

                else if nodeName == "VALUE"
                    if parent.getAttribute("name").toString() == "VALUE"
                        nextUp = parent.parentNode
                        ##|
                        ##|  This should be a variables_set
                        if nextUp.getAttribute("type").toString() == "variables_set"
                            ##|
                            ##|  Target variable found
                            targetName = nextUp.children[0].innerText
                            list[varName] =
                                xml: block
                                target: targetName
                        else
                            console.log "#{varName} assigned to unknown:", nextUp

                    else if parent.getAttribute("name").toString() == "A"
                        ##|
                        ##| Skip a "WITH" assignment
                    else
                        console.log "Unknown usage #{varName}"
                else
                    console.log "Var=#{varName} Name=#{nodeName}", parent

        return list

    ##|
    ##|  Remove a node from the workspace,
    ##|  Example:  @blockly.doRemove "variables_get", "VAR", "DENSITY"
    doRemove: (blockType, fieldName, fieldValue)=>

        xml = Blockly.Xml.workspaceToDom @workspace
        elements = xml.getElementsByTagName("block")
        for block in elements
            thisBlockType = block.getAttribute("type").toString()
            if thisBlockType is blockType and block.children[0]?
                nodeName = block.children[0].getAttribute("name").toString()
                nodeValue = block.children[0].innerText
                if nodeName == fieldName and nodeValue == fieldValue
                    x = parseFloat block.getAttribute("x").toString()
                    y = parseFloat block.getAttribute("y").toString()

                    # block.removeChild block.children[0]
                    block.remove()
                    @workspace.clear();
                    Blockly.Xml.domToWorkspace xml, @workspace

                    console.log "(#{x}, #{y}) REMOVE BLOCK:", block.children[0], nodeName, nodeValue
                    return [x, y]

        return null


    ##|
    ##|  Append a BlocklyCodeBlock block and children to the existing workspace
    ##|
    doAppendBlock: (jsBlock)=>

        globalYValues = {}

        xmlText = @getXmlText()

        ##|
        ##|  Insert the new XML text before the final node
        xmlText = xmlText.replace "</xml>", jsBlock.getXml()+"</xml>"
        xmlDom = Blockly.Xml.textToDom xmlText
        @workspace.clear();
        Blockly.Xml.domToWorkspace xmlDom, @workspace
        true

    ##|
    ##|  Convert the workspace back to XML and Blocks
    doSaveWorkspace: ()=>

        xmlText = @getXmlText()
        @onSaveWorkspace(xmlText)
        true


    ##|
    ##|  Convert saved blocks to a workspace
    ##|  These are internal blocks that we used to quickly build the
    ##|  xml tree, not actually XML blocks.
    ##|
    loadBlocksToWorkspace: ()=>

        Blockly.Events.recordUndo = false

        if @xmlText
            console.log "Loading XML Instead"
            xml = @xmlText
            delete @xmlText

        else

            xml = '<xml xmlns="http://www.w3.org/1999/xhtml">'
            for block in @blocks
                xml += block.getXml()

            xml += "</xml>"

        @workspace.scrollX = -150
        @workspace.scrollY = -10
        @setXmlText xml

        setTimeout ()=>
            ##|
            ##|  Re-enable the UNDO system
            Blockly.Events.recordUndo = true
        , 1000

        true

    ##|
    ##|  Show a dialog that allows adding to or changing the variables to ignore
    ##|
    onShowIgnorePaths : (e) =>

        m = new ModalDialog
            showOnCreate : false
            title        : "Ignore Paths"
            content      : "Enter a list of patterns to hide specific variables"
            position     : "center"
            ok           : "Go"

        console.log "Existing:", @ignoreList
        m.getForm().addTagsInput "tags1", "Ignore Patterns", @ignoreList.join(",")
        m.getForm().onSubmit = (form) =>
            @setIgnore form.tags1.split(",")
            m.hide()
            true

        m.show()
        true

    ##|
    ##|  Show a dialog that allows an assignment to be created from the
    ##|  selected field.
    ##|
    onShowAssignmentDialog: (targetField)=>

        m = new ModalDialog
            showOnCreate: false
            content:      "Enter a variable name to create a new assignment."
            position:     "center"
            title:        "Create Assignment"
            ok:           "Go"

        m.getForm().addTextInput "input1", "Name"
        m.getForm().addTextInput "inputTarget", "Target Variable", targetField
        m.getForm().onSubmit = (form) =>

            window.globalBusyDialog.exec "Creating assignment", ()=>
                result = @doRemove "variables_get", "VAR", form.inputTarget
                node = @createVariableSetToVariable form.input1, form.inputTarget
                if result?
                    node.x = result[0]
                    node.y = result[1]

                console.log "NODE=", node
                @doAppendBlock node
                true

            m.hide()

        m.show()
        true

    ##|
    ##|  See the lst in RetsTools which helps auto-assign rules
    autoAssignFromRules: (rules) =>

        for a, b of @knownVariablesSet
            if @knownVariablesGet[a]?
                @addAssignRule a, a

        for rule in rules
            if @knownVariablesSet[rule[0]]? and @knownVariablesGet[rule[1]]?
                console.log "Matched:", rule
                @addAssignRule rule[1], rule[0]

        true

    ##|
    ##|  Assign one block to another
    addAssignRule: (sourceFieldName, targetFieldName)=>

        src = null
        dst = null

        if @knownVariablesSet[targetFieldName]?
            dst = @knownVariablesSet[targetFieldName]

        if @knownVariablesGet[sourceFieldName]?
            src = @knownVariablesGet[sourceFieldName]

        if src? and dst?
            console.log "Assign #{sourceFieldName} to #{targetFieldName}: ", src, dst
            dst.addChild "VALUE", src
            delete @knownVariablesGet[sourceFieldName]
        else
            console.log "Not found src=#{src}, dst=#{dst}"

        true

    ##|
    ##|  Add an object to the view for the purpose of determining the available fields
    ##|  and the sample values in those fields
    ##|
    addSampleDataRecord: (obj)=>

        for keyVar, keyVal of obj

            if !@sampleData[keyVar]?
                @sampleData[keyVar] = {}

            if !@sampleData[keyVar][keyVal]?
                @sampleData[keyVar][keyVal] = 0

            @sampleData[keyVar][keyVal]++

        true

    ##|
    ##|  Configure the list of predefined variables from a text configuration.
    ##|
    setStandardOptions: (subDocumentSource, subDocumentTarget, configText, checkVariable, checkValue) =>

        configText = configText.replace /^[^a-zA-Z]*/g, ""
        configText = configText.replace /[^a-zA-Z]*$/g, ""

        lastNode = null

        ##|
        ##|  Load sample data and create known fields
        for keyVar, keyVal of @sampleData
            node = @createVariableGet keyVar
            @placeNode node, 600

        withBlock = @createWithCondition subDocumentSource
        withBlock.addChild "WITH", @createOutputTo(subDocumentTarget)

        ##|
        ##|  Load configuration file and create known variables
        for line in configText.split /\n/

            if line

                if /\#/.test line

                    commentText = line.replace /^.*#/, ""
                    node = @createComment commentText

                else

                    node = @createVariableSet line

                if lastNode?
                    lastNode.nextNode = node
                else
                    withBlock.addStatement "COMMANDS", node

                lastNode = node


        varSetId   = @createVariableGet checkVariable
        varTheSet  = @createText checkValue
        logicBlock = @createLogicalEquals varSetId, varTheSet
        mainBlock  = @createIfCondition logicBlock, withBlock
        @placeNode mainBlock, 40
        true


    ##|
    ##|  Convert a text name to a variable slug identifier
    getSlug: (line) =>

        str = line.toLowerCase()
        str = str.replace /[^a-zA-Z0-9]/g, "_"
        str

    ##|
    ##| Put a top level node on the workspace
    placeNode: (node, xValue) =>
        node.x = xValue
        @blocks.push node

    ##|
    ##|  Options List in the form of var, match, replace
    ##|
    createFilterList: (optionsList)=>

        node = new BlocklyCodeBlock "filter_text", 590

        n = 0
        for item in optionsList

            console.log "Adding node for ", item.var

            endNode = new BlocklyCodeBlock "variables_get"
            endNode.addField "VAR", item.var

            subNode = new BlocklyCodeBlock "search_replace"
            subNode.addField "Pattern", item.match
            subNode.addField "Result", item.replace
            subNode.addChild "NEXT", endNode

            node.addChild "ADD#{n}", subNode
            n++

        node.addMutation "items", n
        return node

    ##|
    ##| Create an avilable variable node
    createVariableGet: (varName) =>

        node = new BlocklyCodeBlock "variables_get", 0
        node.addField "VAR", varName
        @knownVariablesGet[varName] = node
        return node

    ##|
    ##| Create a rule that sets a new variable
    createVariableSet: (varName) =>

        node = new BlocklyCodeBlock "variables_set", 0
        node.addField "VAR", varName
        @knownVariablesSet[varName] = node
        @knownVariablesSet[@getSlug(varName)] = node
        return node

    createVariableSetToText: (varName, textValue) =>

        node = @createVariableSet varName

        textNode = new BlocklyCodeBlock "text"
        textNode.addField "TEXT", textValue

        node.addChild "VALUE", textNode
        return node

    createVariableSetToVariable: (varName, targetVariable) =>

        node = @createVariableSet varName

        if !@knownVariablesGet[targetVariable]
            target = @createVariableGet targetVariable
        else
            target = @knownVariablesGet[targetVariable]

        node.addChild "VALUE", target
        return node

    createText: (text) =>

        node = new BlocklyCodeBlock "text", 0
        node.addField "TEXT", text
        return node

    createWithCondition: (varName) =>

        node = new BlocklyCodeBlock "with", 0
        node.addField "name", varName
        return node

    createMathNumber: (numValue) =>

        node = new BlocklyCodeBlock "math_number"
        node.addField "NUM", numValue
        return node

    createComment: (text) =>

        node = new BlocklyCodeBlock "code_comment"
        node.addField "comment_text", text
        return node

    createLogicalEquals: (leftSide, rightSide) =>

        node = new BlocklyCodeBlock "logic_compare"
        node.addField "OP", "EQ"
        node.addChild "A", leftSide
        node.addChild "B", rightSide
        return node

    createLogicalLessthan: (leftSide, rightSide) =>

        node = new BlocklyCodeBlock "logic_compare"
        node.addField "OP", "LT"
        node.addChild "A", leftSide
        node.addChild "B", rightSide
        return node

    createIfCondition: (blockTestValue, statementBlock)=>

        node = new BlocklyCodeBlock "controls_if"
        node.addChild "IF0", blockTestValue
        node.addStatement "DO0", statementBlock
        return node

    createOutputTo: (varName) =>

        node = new BlocklyCodeBlock "output_to"
        node.addField "name", varName
        return node

    toolboxText: ()=>

        return '''<xml id='toolbox' style='display: none;'>
                <category name="Loops" colour="120">
                    <block type="controls_whileUntil" ></block>
                    <block type="controls_for"></block>
                    <block type="controls_flow_statements"></block>
                    <block type="controls_forEach"></block>
                    <block type="controls_repeat_ext">
                        <value name="TIMES">
                            <shadow type="math_number">
                                <field name="NUM">10</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="controls_for">
                        <value name="FROM">
                            <shadow type="math_number">
                                <field name="NUM">1</field>
                            </shadow>
                        </value>
                        <value name="TO">
                            <shadow type="math_number">
                                <field name="NUM">10</field>
                            </shadow>
                        </value>
                        <value name="BY">
                            <shadow type="math_number">
                                <field name="NUM">1</field>
                            </shadow>
                        </value>
                    </block>
                </category>

                <category name="Logic" colour="210">
                    <block type="controls_if"> </block>
                    <block type="logic_compare"> </block>
                    <block type="logic_operation"> </block>
                    <block type="logic_boolean"> </block>
                    <block type="logic_negate"> </block>
                    <block type="logic_ternary"> </block>
                    <block type="logic_null"> </block>
                </category>

                <category id="catMath" colour="230" name="Math">
                    <block type="math_number"></block>
                    <block type="math_arithmetic">
                        <value name="A">
                            <shadow type="math_number">
                                <field name="NUM">1</field>
                            </shadow>
                        </value>
                        <value name="B">
                            <shadow type="math_number">
                                <field name="NUM">1</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="math_single">
                        <value name="NUM">
                            <shadow type="math_number">
                                <field name="NUM">9</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="math_trig">
                        <value name="NUM">
                            <shadow type="math_number">
                                <field name="NUM">45</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="math_constant"></block>
                    <block type="math_number_property">
                        <value name="NUMBER_TO_CHECK">
                            <shadow type="math_number">
                                <field name="NUM">0</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="math_change">
                        <value name="DELTA">
                            <shadow type="math_number">
                                <field name="NUM">1</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="math_round">
                        <value name="NUM">
                            <shadow type="math_number">
                                <field name="NUM">3.1</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="math_on_list"></block>
                    <block type="math_modulo">
                        <value name="DIVIDEND">
                            <shadow type="math_number">
                                <field name="NUM">64</field>
                            </shadow>
                        </value>
                        <value name="DIVISOR">
                            <shadow type="math_number">
                                <field name="NUM">10</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="math_constrain">
                        <value name="VALUE">
                            <shadow type="math_number">
                                <field name="NUM">50</field>
                            </shadow>
                        </value>
                        <value name="LOW">
                            <shadow type="math_number">
                                <field name="NUM">1</field>
                            </shadow>
                        </value>
                        <value name="HIGH">
                            <shadow type="math_number">
                                <field name="NUM">100</field>
                            </shadow>
                        </value>
                    </block>
                </category>
                <category id="catText" colour="160" name="Text">
                    <block type="text"></block>
                    <block type="text_join"></block>
                    <block type="text_append">
                        <value name="TEXT">
                            <shadow type="text"></shadow>
                        </value>
                    </block>
                    <block type="text_length">
                        <value name="VALUE">
                            <shadow type="text">
                                <field name="TEXT">abc</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="text_isEmpty">
                        <value name="VALUE">
                            <shadow type="text">
                                <field name="TEXT"></field>
                            </shadow>
                        </value>
                    </block>
                    <block type="text_indexOf">
                        <value name="VALUE">
                            <block type="variables_get">
                                <field name="VAR">text</field>
                            </block>
                        </value>
                        <value name="FIND">
                            <shadow type="text">
                                <field name="TEXT">abc</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="text_charAt">
                        <value name="VALUE">
                            <block type="variables_get">
                                <field name="VAR">text</field>
                            </block>
                        </value>
                    </block>
                    <block type="text_getSubstring">
                        <value name="STRING">
                            <block type="variables_get">
                                <field name="VAR">text</field>
                            </block>
                        </value>
                    </block>
                    <block type="text_changeCase">
                        <value name="TEXT">
                            <shadow type="text">
                                <field name="TEXT">abc</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="text_trim">
                        <value name="TEXT">
                            <shadow type="text">
                                <field name="TEXT">abc</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="text_print">
                        <value name="TEXT">
                            <shadow type="text">
                                <field name="TEXT">abc</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="text_prompt_ext">
                        <value name="TEXT">
                            <shadow type="text">
                                <field name="TEXT">abc</field>
                            </shadow>
                        </value>
                    </block>
                </category>
                <category id="catLists" colour="260" name="Lists">
                    <block type="lists_create_with">
                        <mutation items="0"></mutation>
                    </block>
                    <block type="lists_create_with"></block>
                    <block type="lists_repeat">
                        <value name="NUM">
                            <shadow type="math_number">
                                <field name="NUM">5</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="lists_length"></block>
                    <block type="lists_isEmpty"></block>
                    <block type="lists_indexOf">
                        <value name="VALUE">
                            <block type="variables_get">
                                <field name="VAR">list</field>
                            </block>
                        </value>
                    </block>
                    <block type="lists_getIndex">
                        <value name="VALUE">
                            <block type="variables_get">
                                <field name="VAR">list</field>
                            </block>
                        </value>
                    </block>
                    <block type="lists_setIndex">
                        <value name="LIST">
                            <block type="variables_get">
                                <field name="VAR">list</field>
                            </block>
                        </value>
                    </block>
                    <block type="lists_getSublist">
                        <value name="LIST">
                            <block type="variables_get">
                                <field name="VAR">list</field>
                            </block>
                        </value>
                    </block>
                    <block type="lists_split">
                        <value name="DELIM">
                            <shadow type="text">
                                <field name="TEXT">,</field>
                            </shadow>
                        </value>
                    </block>
                    <block type="lists_sort"></block>
                </category>

                <sep></sep>
                <category id="catFunctions" colour="290" custom="PROCEDURE" name="Functions"></category>
                <sep></sep>

                <category id="customer1" colour="310" name="Portal Custom">
                    <block type="code_comment"></block>
                    <block type="with"></block>
                    <block type="concat"></block>
                    <block type="make_date"></block>
                    <block type="output_to"></block>
                    <block type="extract"></block>
                    <block type="search_replace"></block>
                    <block type="days_from_today"></block>
                    <block type="filter_text"></block>
                </category>

            </xml>
        '''
