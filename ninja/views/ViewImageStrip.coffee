##|
##|  To help with automated testing
globalImageCounter = 0

class ViewImageStrip extends View
    ## ------------------------------------------------------------------------------------------
    ## function to set data of image sources
    ##
    setImgData: (@imageData)=>
        return @imageData
    
    ##
    ## default function of class View that is necessary 
    ##
    onSetupButtons: () =>

    ##
    ## default function of class View
    ##    
    setTitle: (title)=>

    ## ------------------------------------------------------------------------------------------
    ## function to add an image source data
    ##    
    addImage: (image)=>
        unless image? then return
        if !@imageData? then @imageData = []
        if image.tagName is "IMG"
            @imageData.push image
        else
            newImg = new Image()
            newImg.src = image
            @imageData.push(newImg)

        return image
    ##
    ## function to change width and height of the view when it is resized
    ##
    onResizeViewImageStrip : (w, h)=>
        if w < 400 or h < 400
            @setThumbSize 100, 75
        else if w < 600 or h < 600
            @setThumbSize 150, 100
        else if w < 900 or h < 900
            @setThumbSize 200, 150
        else
            @setThumbSize 300, 200
        true

    ##
    ## function to set width and height of View
    ##
    setSize: (w, h)=>
        if w > 0
            @elHolder.width w
        if h > 0
            @elHolder.height h
        true

    ## ------------------------------------------------------------------------------------------
    ## function to render entire ImageStrip including imageviewer, thumbnail list, control buttons
    ##    
    render: ()=>        
        @renderThumbList()
        @renderControls()
        if !@setSelectedImgNumber(0)?
            return false
        true

    ## ------------------------------------------------------------------------------------------
    ## function to initialize class, creates ImageViewer    
    ##
    init: ()=>
        @elHolder.find(".imageHolder").html("<div class='image' id='image#{@gid}'/><div class='controls' id='controls#{@gid}'/>")
        @elHolder.find(".scroll_wrapper").attr("id", "scroll_wrapper#{@gid}")
        @imageViewer = new ImageViewer @elHolder.find("#image#{@gid}")
        @selectedImgNumber = 0
        @setImgData []
        @on "resize", @onResizeViewImageStrip
        true

    ## 
    ## function to send data to imageviewer, then imageviewer renders the data
    ##
    setElementsImageData: ()=>
        if !@imageData?
            return false
        @imageViewer.setData {
                image: @imageData[@selectedImgNumber]
                number: @selectedImgNumber
            }
        true

    ##
    ## function to set currently selected image's number
    ##
    setSelectedImgNumber: (number)=>
        if number? and 0 <= number and number < @getImageCount()
            @selectedImgNumber = number
            @hideOrShowControls()
            return @setElementsImageData()
        else
            return false
    
    ##
    ## function to get currently selected image number
    ##    
    getSelectedImgNumber: ()=>
        @selectedImgNumber

    ##
    ## function to get number(counted) of images
    ##
    getImageCount: ()=>
        @imageData.length

    ##
    ## function to set number as current's-1
    ##
    prevImg: ()=>
        @setSelectedImgNumber @selectedImgNumber-1
        true

    ##
    ## function to set number as current's+1
    ##    
    nextImg: ()=>
        @setSelectedImgNumber @selectedImgNumber+1
        true

    ##
    ## function to show right and left arrow controls
    ##    
    renderControls: ()=>
        html = "<div id='left-arrow'><i class='fa fa-arrow-left fa-3x' aria-hidden='true'></i></div><div id='right-arrow'><i class='fa fa-arrow-right fa-3x' aria-hidden='true'></i></div>"
        $("#controls#{@gid}").html html
        $("#controls#{@gid} #left-arrow").bind "click", =>
            @prevImg()
            
        $("#controls#{@gid} #right-arrow").bind "click", =>
            @nextImg()

    ##
    ## Function to enable/disable arrow buttons as there is any previous/next images
    ##
    hideOrShowControls: ()=>
        if @selectedImgNumber <= 0
                $("#controls#{@gid} #left-arrow").addClass "hidden-arrow"
            else
                $("#controls#{@gid} #left-arrow").removeClass "hidden-arrow"
        if @selectedImgNumber >= @getImageCount() - 1
                $("#controls#{@gid} #right-arrow").addClass "hidden-arrow"
            else
                $("#controls#{@gid} #right-arrow").removeClass "hidden-arrow"

    ##
    ## function to finally load IScroll for thumbnail list
    ##        
    loadScroll: ()=>
        @iScroll = new IScroll document.getElementById("scroll_wrapper#{@gid}"), { mouseWheel: true, click: true, tap: true, resizeScrollbars: true }

    ##
    ## function to render thumbnail list(list of imageviewers that are smaller than main one)
    ##
    renderThumbList: ()=>
        @scrollListBody = new WidgetTag "div", "scroll_list_body", "scroller#{@gid}"
        @element_ul = @scrollListBody.add "ul"
        @imageData.forEach((image, index)=>
            element_li = @element_ul.add "li"
            element_li.el.on('click, tap', (e)=>
                e.preventDefault()
                @setSelectedImgNumber index
            )
            imageviewer = new ImageViewer element_li.el, image, index
            imageviewer.render()
            imageviewer.setSize "200px", "150px"
        )        
        $("#scroll_wrapper#{@gid}").append @scrollListBody.el
        @loadScroll()

    ##
    ## Function to set size of thumbnails in IScroll
    ##
    setThumbSize: (w, h) =>
        thumbList = @element_ul.getChildren()
        for thumb in thumbList
            thumb.el.width w
            thumb.el.height h
        @iScroll.refresh()
        true