##|
##|  Represents a single block of code
##|

globalYValues = {}


class BlockyHelper

    ##|
    ##| Resize blockly if loaded
    onResizeEditor: ()=>

        $(".PopupWindow").css "zIndex", 1100
        # $(".blocklyWidgetDiv").css "zIndex", 51001

        if @elBlocklyDiv?

            x = 0
            y = 0
            element = @divBlocklyArea[0]
            loop
                x += element.offsetLeft
                y += element.offsetTop
                element = element.offsetParent
                if not element then break
                break

            x += @toolboxWidth

            window.dba = @divBlocklyArea[0]
            console.log "BlocklyHelper onResizeEditor, Offset Width=", @divBlocklyArea[0].offsetWidth, " x=#{x}, y=#{y}"

            @elBlocklyDiv.css
                position : "absolute"
                left     : x
                top      : y
                width    : @divBlocklyArea[0].offsetWidth-@toolboxWidth
                height   : @blocklyMaxScrollHeight
                # zIndex   : @blocklyZindex

            ##|
            ##|  Create the toolbox the first time
            ##|
            if !@toolboxDiv
                @toolboxDiv = $(".blocklyToolboxDiv").detach()
                @toolboxDiv.appendTo @divBlocklyArea

                Blockly.Toolbox.prototype.position = ()->
                    if this.flyout_?
                        return this.flyout_.position();
                    return null

                Blockly.Flyout.prototype.position = ()->
                    if !this.isVisible()
                        return

                    ##|
                    ##|  Give the blockly flyout a width of 400 for the toolbox
                    ##|
                    targetWorkspaceMetrics = this.targetWorkspace_.getMetrics()
                    if !toolboxFlyoutWidth? then @toolboxFlyoutWidth = 400
                    console.log "calling ", this.setBackgroundPath_, " with ", @toolboxFlyoutWidth, targetWorkspaceMetrics.viewHeight
                    this.setBackgroundPath_(@toolboxFlyoutWidth, targetWorkspaceMetrics.viewHeight);

            @toolboxDiv.css
                width  : @toolboxWidth
                left   : 0
                top    : 0
                # zIndex : @blocklyZindex+1

            @workspace.markFocused()
            Blockly.svgResize(@workspace)

        true




