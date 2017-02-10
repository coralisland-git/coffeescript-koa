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
        console.log "w: #{w},   h: #{h}"
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
        if !@setElementsImageData()?
            return false
        @renderThumbList()
        @renderControls()
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
            @imageViewer.setData {
                image: @imageData[@selectedImgNumber]
                number: @selectedImgNumber
                }
        true
    
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
        if @selectedImgNumber == 0 then return
        @selectedImgNumber--
        @imageViewer.setData {
            image: @imageData[@selectedImgNumber]
            number: @selectedImgNumber
        }
        true

    ##
    ## function to set number as current's+1
    ##    
    nextImg: ()=>
        if @selectedImgNumber >= @getImageCount() - 1 then return
        @selectedImgNumber++
        @imageViewer.setData {
            image: @imageData[@selectedImgNumber]
            number: @selectedImgNumber
        }
        true

    ##
    ## function to show right and left arrow controls
    ##    
    renderControls: ()=>
        btnLeftArrow = new WidgetTag "button", "arrow_left"
        btnRightArrow = new WidgetTag "button", "arrow_right"
        btnLeftArrow.appendTo "#controls#{@gid}"
        btnRightArrow.appendTo "#controls#{@gid}"
        btnLeftArrow.bind "click", =>
            console.log "Left Arrow Clicked"
            @prevImg()
        btnRightArrow.bind "click", =>
            console.log "Right Arrow Clicked"
            @nextImg()

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
        element_ul = @scrollListBody.add "ul"
        #_this = this
        @imageData.forEach((image, index)=>
            element_li = element_ul.add "li"
            element_li.el.on('click, tap', (e)=>
                e.preventDefault()
                console.log "thumb clicked : " + index
                @setSelectedImgNumber index
            )
            imageviewer = new ImageViewer element_li.el, image, index
            imageviewer.render()
            imageviewer.setSize "200px", "150px"
        )        
        $("#scroll_wrapper#{@gid}").append @scrollListBody.el
        @loadScroll()