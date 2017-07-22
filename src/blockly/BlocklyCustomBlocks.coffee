root = exports ? this
root.setupCustomBlockly = {}

root.setupCustomBlockly.setupBlocks = (Blockly, callbackContext) ->

    Blockly.Blocks['filter_text'] =
        init: ()->
            this.setColour(12)
            this.itemCount_ = 30
            this.updateShape_()
            this.setOutput(true, 'Array')
            # this.setMutator(new Blockly.Mutator(['lists_create_with_item']))

        #
        # Create XML to represent list inputs.
        # @return {Element} XML storage element.
        # @this Blockly.Block
        #
        mutationToDom: ()->
            container = document.createElement('mutation')
            container.setAttribute('items', this.itemCount_)
            this.updateShape_()
            container

        # Parse XML to restore the list inputs.
        # @param {!Element} xmlElement XML storage element.
        # @this Blockly.Block
        #
        domToMutation: (xmlElement)->
            this.itemCount_ = parseInt(xmlElement.getAttribute('items'), 10);


        saveConnections: (containerBlock)->
            itemBlock = containerBlock.getInputTargetBlock('STACK');

            i = 0;
            while (itemBlock)
                input = this.getInput('ADD' + i);
                itemBlock.valueConnection_ = input && input.connection.targetConnection;

                i++;
                itemBlock = itemBlock.nextConnection && itemBlock.nextConnection.targetBlock()

            true

        onchange: (e)->
            if e.type == Blockly.Events.MOVE
                if @eventTimer?
                    clearTimeout(@eventTimer)
                @eventTimer = setTimeout ()=>
                    this.updateShape_(true)
                , 50

            true

        updateShape_ : (doRecount)->

            if doRecount? and doRecount

                delete @eventTimer
                totalCount = 0
                for n in [0..this.itemCount_]
                    input = this.getInput("ADD#{n}")
                    if input? and input.connection.targetConnection?
                        totalCount++

                if totalCount < 1 then totalCount = 1
                this.itemCount_ = totalCount+1

            if (this.itemCount_ && this.getInput('EMPTY'))
                this.removeInput('EMPTY');
            else if (!this.itemCount_ && !this.getInput('EMPTY'))
                this.appendDummyInput 'EMPTY'
                .appendField "Filter list is empty"

            for i in [0...this.itemCount_]
                if !this.getInput("ADD#{i}")
                    input = this.appendValueInput "ADD#{i}"
                    if i == 0
                        input.appendField "Use first match"

            if doRecount? and doRecount
                ##|
                ##|  Remove extra inputs
                for i in [0..30]
                    n = i + this.itemCount_
                    if this.getInput("ADD#{n}")
                        this.removeInput("ADD#{n}")

            true

    Blockly.Blocks['days_from_today'] =
        init: ()->
            this.appendValueInput("NAME")
                .setCheck(null)
                .appendField("Extract Value")

            this.appendValueInput("WITH")
            .setCheck(null)
            .appendField "With"
            .appendField new Blockly.FieldTextInput("prop"), "name"

            this.setOutput(true, null);
            this.setColour  40
            true

    Blockly.Blocks['extract'] =
        init: ()->
            this.appendValueInput("NAME")
                .setCheck(null)
                .appendField("Extract Value")
                .appendField(new Blockly.FieldDropdown([["Decimal", "parseFloat"], ["Number", "parseInt"], ["Currency", "this.parseCurrency"]]), "TYPE");
            this.setOutput(true, null);
            this.setColour  40
            true

    Blockly.Blocks['output_to'] =
        init: ()->

            this.setColour  23
            this.appendDummyInput()
            .appendField "output to"
            # .appendField new Blockly.FieldVariable(Blockly.Msg.VARIABLES_DEFAULT_NAME), "VAR"
            .appendField new Blockly.FieldTextInput("Property"), "name"
            this.setOutput true
            true

    Blockly.Blocks['search_replace'] =
        init: ()->

            this.setColour  90
            this.setOutput(true, null)
            this.appendValueInput("NEXT")
            .setCheck(null)
            .appendField "match /"
            .appendField new Blockly.FieldTextInput(""), "Pattern"
            .appendField "/ return"
            .appendField new Blockly.FieldTextInput(""), "Result"
            true

        validator_: (newVar)->
            return newVar

    Blockly.Blocks['variables_get'] =
        init: ()->

            this.setColour  238
            this.appendDummyInput()
            .appendField new Blockly.FieldVariable(Blockly.Msg.VARIABLES_DEFAULT_NAME), "VAR"
            this.setOutput true
            this.setTooltip Blockly.Msg.VARIABLES_GET_TOOLTIP
            this.contextMenuMsg_ = Blockly.Msg.VARIABLES_GET_CREATE_SET
            true

        customContextMenu: (options)->

            if callbackContext?

                name = this.getFieldValue('VAR')
                options.push
                    text: "Generate Filter"
                    enabled: true
                    callback: (e)->
                        callbackContext.emitEvent "GenerateFilter", [ name ]
                        true

                options.push
                    text: "Ignore Variable"
                    enabled: true
                    callback: (e)->
                        callbackContext.emitEvent "IgnoreVariable", [ name, e ]
                        true

                # options.push
                #     text: "Show Samples"
                #     enabled: true
                #     callback: (e)->
                #         callbackContext.emitEvent "ShowSamples", [ name ]
                #         true

                options.push
                    text: "Create Assignment"
                    enabled: true
                    callback: (e)->
                        callbackContext.emitEvent "CreateAssignment", [ name ]
                        true
            true

    Blockly.Blocks['code_comment']  =
        init: ()->
            this.setColour(120)
            this.setPreviousStatement(true, null)
            this.setNextStatement(true, null)
            this.appendValueInput("CodeComment")
            .setCheck(null)
            .appendField "Comment "
            .appendField new Blockly.FieldTextInput("Comment Text"), "comment_text"

    Blockly.Blocks['with'] =
        init: ()->
            this.setColour 100
            this.setPreviousStatement(true, null)
            this.setNextStatement(true, null)

            this.appendValueInput("WITH")
            .setCheck(null)
            .appendField "With"
            .appendField new Blockly.FieldTextInput("prop"), "name"

            this.appendStatementInput("COMMANDS")
            .setCheck(null)

            this.setTooltip "Using a document within the object"

        validator_: (newVar)->
            console.log "Validate:", newVar
            return newVar

    Blockly.Blocks['concat'] =
        init: ()->
            this.appendDummyInput()
            .appendField("concat");

            this.appendValueInput("VAR1")
            .setCheck(null);

            this.appendDummyInput()
            .appendField(new Blockly.FieldTextInput(" "), "middle");

            this.appendValueInput("VAR2")
            .setCheck(null);

            this.setInputsInline(true);
            this.setOutput(true, null);
            this.setColour(15);
            this.setTooltip('Concat 2 variables together with text in the middle');

    Blockly.Blocks['make_date'] =
        init: ()->
            this.appendDummyInput()
            .appendField("Date");

            this.appendValueInput("YEAR")
            .setCheck(null);

            this.appendDummyInput()
            .appendField("-");

            this.appendValueInput("MONTH")
            .setCheck(null);

            this.appendDummyInput()
            .appendField("-");

            this.appendValueInput("DAY")
            .setCheck(null);

            this.setInputsInline(true);
            this.setOutput(true, null);
            this.setColour(15);
            this.setTooltip('Create a new date');

    Blockly.JavaScript['make_date'] = (block) =>
        year  = Blockly.JavaScript.valueToCode(block, 'YEAR', Blockly.JavaScript.ORDER_ATOMIC);
        month  = Blockly.JavaScript.valueToCode(block, 'MONTH', Blockly.JavaScript.ORDER_ATOMIC);
        day  = Blockly.JavaScript.valueToCode(block, 'MONTH', Blockly.JavaScript.ORDER_ATOMIC);

        code = "new Date(#{year} + '-' + #{month} + '-' + #{day} + ' 0:00:00')"
        return [code, Blockly.JavaScript.ORDER_NONE];

    Blockly.JavaScript['concat'] = (block) =>
        value_var1  = Blockly.JavaScript.valueToCode(block, 'VAR1', Blockly.JavaScript.ORDER_ATOMIC);
        text_middle = block.getFieldValue('middle');
        value_var2  = Blockly.JavaScript.valueToCode(block, 'VAR2', Blockly.JavaScript.ORDER_ATOMIC);

        code  = "(function(){ var _a = #{value_var1};"
        code += "var _b = #{value_var2};"
        code += "var _c = '';"
        code += "if (_a != null) _c = _a + '#{text_middle}';"
        code += "if (_b != null) _c += _b; return _c;"
        code += "})()"

        return [code, Blockly.JavaScript.ORDER_NONE];

    Blockly.JavaScript['search_replace'] = (block)=>
        ##|
        ##|  With condition With __Folder__ output to __new Folder__
        text_pattern = block.getFieldValue('Pattern');
        text_result = block.getFieldValue('Result');
        value_with = Blockly.JavaScript.valueToCode(block, 'NEXT', Blockly.JavaScript.ORDER_ATOMIC);
        code = "obj.searchReplace('#{text_pattern}', '#{text_result}', #{value_with})"
        return [code, Blockly.JavaScript.ORDER_ATOMIC];

    Blockly.JavaScript['with'] = (block)=>
        ##|
        ##|  With condition With __Folder__ output to __new Folder__
        varName = block.getFieldValue('name')
        arg = Blockly.JavaScript.valueToCode(block, "WITH", Blockly.JavaScript.ORDER_ASSIGNMENT)
        branch = Blockly.JavaScript.statementToCode block, "COMMANDS"
        code = "if (obj.setWith('#{varName}', #{arg})) {\n" + branch + "\n}\n"
        code += "obj.resetBase();\n"
        code

    Blockly.JavaScript['days_from_today'] = (block)=>
        ##|
        ##|  With condition With __Folder__ output to __new Folder__
        varName = block.getFieldValue('name')
        arg = Blockly.JavaScript.valueToCode(block, "WITH", Blockly.JavaScript.ORDER_ASSIGNMENT)
        branch = Blockly.JavaScript.statementToCode block, "COMMANDS"
        code = "obj.getDaysFromToday(#{arg});\n"
        code

    Blockly.JavaScript['output_to'] = (block)=>
        ##|
        ##|  With condition With __Folder__ output to __new Folder__
        varName = block.getFieldValue('name')
        if not /^obj/.test varName
            varName = "'" + varName + "'"
        code = "obj.setOutputTo(#{varName})"
        return [code, Blockly.JavaScript.ORDER_ATOMIC];

    Blockly.JavaScript['variables_set'] = (block)=>
        arg = Blockly.JavaScript.valueToCode(block, 'VALUE', Blockly.JavaScript.ORDER_ASSIGNMENT)
        varName = block.getFieldValue('VAR')
        if arg
            return "obj.set('#{varName}', #{arg});\n"
        else
            return ""

    Blockly.JavaScript['variables_get'] = (block)=>
        # varName = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('VAR'), Blockly.Variables.NAME_TYPE)
        varName = block.getFieldValue('VAR')
        varName = varName.replace "'", ""
        # console.log "variables_get:", varName
        return ["obj.get('#{varName}')", Blockly.JavaScript.ORDER_ATOMIC];

    Blockly.JavaScript['code_comment'] = (block)=>
        code = '';
        return code

    Blockly.JavaScript['extract'] = (block)=>
        dropName = block.getFieldValue('TYPE')
        valueName = Blockly.JavaScript.valueToCode(block, 'NAME', Blockly.JavaScript.ORDER_ATOMIC);

        code = ''
        if valueName?
            code = "#{dropName}(#{valueName})"

        return [code, Blockly.JavaScript.ORDER_NONE]

    Blockly.JavaScript['filter_text'] = (block)->

        code = "(function(){\n"
        for n in [0...block.itemCount_]
            tmpVal = Blockly.JavaScript.valueToCode(block, 'ADD' + n, Blockly.JavaScript.ORDER_COMMA)
            if tmpVal
                code += "tmpVal = " + tmpVal + ";\n"
                code += "if (tmpVal) return tmpVal;\n"
        code += "})()"

        return [code, Blockly.JavaScript.ORDER_ATOMIC];

