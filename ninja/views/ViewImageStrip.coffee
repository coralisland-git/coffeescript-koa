##|
##|  To help with automated testing
globalImageCounter = 0

class ViewImageStrip extends View
    ##|
    ##|  Add Data
    setImgData: (@imageData)=>
        return @imageData
    onSetupButtons: () =>

    setTitle: (title)=>

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

    onResize : (w, h)=>

    setSize: (w, h)=>
        true
    render: ()=>
        if !@setElementsImageData()?
            return false
        @renderThumbList()
        @renderControls()
        true

    init: ()=>
        @elHolder.find(".imageHolder").html("<div class='image' id='image#{@gid}'/><div class='controls' id='controls#{@gid}'/>")
        @elHolder.find(".scroll_wrapper").attr("id", "scroll_wrapper#{@gid}")
        @imageViewer = new ImageViewer @elHolder.find("#image#{@gid}")
        @selectedImgNumber = 0
        true

    setElementsImageData: ()=>
        if !@imageData?
            return false
        @imageViewer.setData {
                image: @imageData[@selectedImgNumber]
                number: @selectedImgNumber
            }
        true

    setSelectedImgNumber: (number)=>
        if number? and 0 <= number and number < @getImageCount()
            @selectedImgNumber = number
            @imageViewer.setData {
                image: @imageData[@selectedImgNumber]
                number: @selectedImgNumber
                }
        true
        
    getSelectedImgNumber: ()=>
        @selectedImgNumber
    getImageCount: ()=>
        @imageData.length
    prevImg: ()=>
        if @selectedImgNumber == 0 then return
        @selectedImgNumber--
        @imageViewer.setData {
            image: @imageData[@selectedImgNumber]
            number: @selectedImgNumber
        }
        true
    nextImg: ()=>
        if @selectedImgNumber >= @getImageCount() - 1 then return
        @selectedImgNumber++
        @imageViewer.setData {
            image: @imageData[@selectedImgNumber]
            number: @selectedImgNumber
        }
        true
    refreshImg:(index)->
        console.log "refreshing"
        @imageViewer.setSelectedImgNumber index
        true
   
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

    loadScroll: ()=>
        @iScroll = new IScroll document.getElementById("scroll_wrapper#{@gid}"), { mouseWheel: true, click: true, tap: true, resizeScrollbars: true }
        #@iScroll.refresh()
        _this = this
        $("#scroller li").on('click, tap', (e)->
            e.preventDefault()
            console.log "thumb clicked : " + $(this).prevAll().length
            _this.setSelectedImgNumber $(this).prevAll().length
        )
    renderThumbList: ()=>
        @scrollListBody =new WidgetTag "div", "scroll_list_body", "scroller"
        element_ul = @scrollListBody.add "ul"
        @imageData.forEach((image, index)->
            element_li = element_ul.add "li"
            imageviewer = new ImageViewer element_li.el, image, index
            imageviewer.render()
            imageviewer.setSize "200px", "150px"
            
        )        
        $("#scroll_wrapper#{@gid}").append @scrollListBody.el
        @loadScroll()