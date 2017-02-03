##|
##|  To help with automated testing
globalImageCounter = 0
class ViewImageStrip extends View

    getDependencyList: ()=>
        true

    onSetupButtons: () =>
        console.log "ViewImageStrip onSetupButtons holder=", @elHolder

    onShowScreen: ()=>
        console.log "ViewImageStrip onShowScreen holder=", @elHolder
        @imageOptions = {}
        
    setTitle: (title)=>
        @imageOptions.title =
            text            : title
            fontSize        : 18
            horizontalAlign : "right"
        return @imageOptions.title

    ##|
    ##|  Add a DataSeries object
    setImgData: (@imageData)=>
        return @imageData

    addImage: (image)=>
        if !@imageData? then @imageData = []
        @imageData.push image
        return image

    onResize : (w, h)=>
        return


    setSize: (w, h)=>
        @elHolder.width(w)
        @elHolder.height(h)
        @elHolder.find("#image#{@gid}").width(w).height(h);

        if @image?
            return @onRender()

        true
    renderImageViewer: ()=>
        @imageViewer.render()
    render: ()=>
        if !@setElementsImageData()?
            return false
        @imageViewer.render()
        @thumbList.render()
        @renderControls()
        true
    show: ()=>
        @render()
        true
    init: ()=>
        @elHolder.find(".imageHolder").html("<div id='image#{@gid}'/><div id='controls'/>")
        firstImage = null
        firstNumber = -1
        if Array.isArray(images) is true
            setImgData images
            firstImage = images[0]
            firstNumber = 0
        else 
            images = null
        @imageViewer = new ImageViewer @elHolder.find("#image#{@gid}"), firstImage, firstNumber
        @thumbList = new ThumbScrollList @elHolder.find("#scroll_wrapper"), images  
        @selectedImgNumber = 0
        true
    setElementsImageData: ()=>
        if !@imageData?
            return false
        @imageViewer.setData {
                image: @imageData[@selectedImgNumber]
                number: @selectedImgNumber
            }
        @thumbList.setImages {
                images: Array.from @imageData 
                number: @selectedImgNumber
            }
        true

    setSelectedImgNumber: (@selectedImgNumber)=>
        
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
        @renderImageViewer()
        true
    nextImg: ()=>
        if @selectedImgNumber >= @getImageCount() - 1 then return
        @selectedImgNumber++
        @imageViewer.setData {
            image: @imageData[@selectedImgNumber]
            number: @selectedImgNumber
        }
        @renderImageViewer()
        true
    refreshImg:(index)->
        console.log "refreshing"
        @imageViewer.setSelectedImgNumber index
        @imageViewer.render()
        true
   
    appendImage: (el, image)->
        for elem in el
            $(image).wrap(elem)
            $(image).width "100%"

    renderControls: ()=>
        @elHolder.find("#controls").html "<span class='arrow_left'><<==</span><span class='numberCircle'>5</span><span class='arrow_right'>==>></span>"
        self =  this
        $("#controls span.arrow_right").click( ->
            console.log "Right arrow clicked"
            self.nextImg()
        )
        $("#controls span.arrow_left").click( ->
            console.log "Left arrow clicked"
            self.prevImg()
        )


class ThumbScrollList
    constructor:(holderElement, images)->
        @listWrapper = $ holderElement

        @imageList = images? images : []

        @selectedImgNumber

        @scrollListBody =
            $ "<div></div>",
            class: "scroll_list_body"
            id: "scroller"

    setImages: (data)=>
        if data.images?
            @imageList = data.images
        if data.number?
            @selectedImgNumber = data.number
    getImages: ()=>
        @imageList

    loadScroll: ()=>
        @iScroll = new IScroll @listWrapper[0], { mouseWheel: true, click: true }

    render: ()=>
        @scrollListBody.append($ "<ul></ul>")
        element_ul = @scrollListBody.find "ul"
        for image, i in @imageList
            htmlOfCurrentThumb = $ "<li></li>"
            htmlOfCurrentThumb.addClass "thumbnail"
            htmlOfCurrentThumb.data "index", "#{i}"
            htmlOfCurrentThumb.css "background-image", "url(#{image.src})"
            htmlOfCurrentThumb.append($ "<span class='numberCircle_Small'>#{i+1}</span>")
            element_ul.append htmlOfCurrentThumb
        
        @listWrapper.append @scrollListBody
        @loadScroll()

    render1: ()=>
        @scrollListBody.append($ "<ul></ul>")
        element_ul = @scrollListBody.find "ul"
        @imageList.forEach((image, index)->
            htmlOfCurrentThumb = $ "<li></li>"
            element_ul.append htmlOfCurrentThumb
            imageviewer = new ImageViewer htmlOfCurrentThumb, image, index
            imageviewer.render()
            console.log index
        )
        
        @listWrapper.append @scrollListBody
        @loadScroll()
