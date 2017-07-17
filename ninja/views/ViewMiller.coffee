##|
##|  To help with automated testing

class ViewMiller extends View

    getDependencyList: ()=>
        return ["/vendor/miller.min.js"]

    onSetupButtons: () ->

    onShowScreen: ()=>


    ##|
    ##|  Add a Data as object to miller columns
    setData: (@optionsData)=>
    

    onResize : (w, h)=>
        return


    setSize: (w, h)=>
        @elHolder.width(w)
        @elHolder.height(h)

    show: (name)=>
        if @millerColumn? then return

        @gid = GlobalValueManager.NextGlobalID()
        if name? then @gid = name
        @elHolder.find(".miller-container").html("<div id='miller#{@gid}'/>")
        @millerColumn = new MillerColumns @elHolder.find("#miller#{@gid}"), true
        @millerColumn.setData @optionsData
        @millerColumn.render()
        true
