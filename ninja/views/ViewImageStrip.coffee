##|
##|  To help with automated testing
globalImageCounter = 0
imageStripButtonSize = 42
imageStripButtonOffset = 10

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

    ##|
    ##|  Loop through all thumbnails and give them a valid height
    resizeThumbnails: ()=>
        ##|
        ##|  Nothing needed here, all done in CSS
        @resizeSelectedImage()
        true

    resizeSelectedImage: ()=>

        totalHeight = @height()
        currentTop  = @splitter1.getSecond().scrollTop()

        for idx, data of @imageData
            if "#{idx}" == "#{@selectedImgNumber}"
                data.li.addClass "selected"
                ##|
                ##|  scroll into view only if not already in view
                if (totalHeight - data.li.offsetTop() + currentTop < 0)
                    data.li.element.scrollIntoView(
                        behavior: "smooth"
                        block: "start"
                    )
                else if (data.li.offsetTop() - currentTop < 0)
                    data.li.element.scrollIntoView(
                        behavior: "smooth"
                        block: "end"
                    )
            else
                data.li.removeClass "selected"

        if @selectedImgNumber? and @imageData[@selectedImgNumber]?

            @imageViewHolder.el.attr("src", @imageData[@selectedImgNumber].src)
            width = @splitter1.getFirst().width()
            height = @splitter1.getFirst().height()
            ratio1 = width / @imageData[@selectedImgNumber].w
            ratio2 = height / @imageData[@selectedImgNumber].h
            if ratio1 < ratio2
                newWidth = ratio1 * @imageData[@selectedImgNumber].w
                newHeight = ratio1 * @imageData[@selectedImgNumber].h
            else
                newWidth = ratio2 * @imageData[@selectedImgNumber].w
                newHeight = ratio2 * @imageData[@selectedImgNumber].h

            newWidth = Math.floor(newWidth)
            newHeight = Math.floor(newHeight)

            offsetX = (width - newWidth) / 2
            offsetY = (height - newHeight) / 2

            # @imageViewHolder.setWidth(Math.floor(newWidth))
            # @imageViewHolder.setHeight(Math.floor(newHeight))
            @imageViewHolder.move offsetX, offsetY, newWidth, newHeight

            if @selectedImgNumber >= @imageData.length - 1
                @btnRight.hide()
            else
                @btnRight.show()
                # @btnRight.move imageStripButtonOffset, (height/2)-(imageStripButtonSize/2), imageStripButtonSize, imageStripButtonSize

            if @selectedImgNumber <= 0
                @btnLeft.hide()
            else
                @btnLeft.show()
                # @btnLeft.move w-imageStripButtonOffset-imageStripButtonSize, (height/2)-(imageStripButtonSize/2), imageStripButtonSize, imageStripButtonSize

            true


    ## ------------------------------------------------------------------------------------------
    ## function to add an image source data
    ##    
    addImage: (image)=>
        unless image? then return

        if !@thumbsList?
            setTimeout @addImage, 100, image
            return

        if !@imageData? then @imageData = []

        if typeof image == "object" and image.src?
            image = image.src

        ##|
        ##|  Load a new image
        img = new Image()
        img.onload = (o)=>

            imageDataOne =
                src: img.src
                w  : img.naturalWidth
                h  : img.naturalHeight

            ##|
            ##|  Create thumbnail holder
            ##|
            imageDataOne.li = @thumbsList.add "li", "imagethumb"
            imageDataOne.elImage = imageDataOne.li.add "img"
            imageDataOne.elImage.el.attr("src", img.src)

            imageDataOne.li.css "cursor", "pointer"
            imageDataOne.li.el.attr "data-id", @imageData.length

            imageDataOne.li.bind "click", (e)=>
                @setSelectedImgNumber parseInt($(e.currentTarget).attr("data-id"))

            elNumber = imageDataOne.li.addDiv "number_body"
            elNumber.html @imageData.length+1

            @imageData.push imageDataOne
            @resizeThumbnails()

        img.onerror = (o)=>
            console.log "ViewImageStrip addImage error:", image, o

        img.src = image
        return true

    ##|
    ##|  Create the HTML Controls that make this work
    createControls: ()=>

        if @thumbsList? then return

        @setView "Splittable", (splitter1)=>

            @splitter1 = splitter1
            @splitter1.setPercent 90
            @splitter1.getSecond().setMinWidth 140
            @splitter1.getSecond().css "backgroundColor", "#bbbbbb"

            @thumbsList = splitter1.getSecond().add "ul", "scroll_list"
            @splitter1.getSecond().setScrollable()

            @imageViewHolder = @splitter1.getFirst().add "img"
            @splitter1.getSecond().onResize = @resizeThumbnails

            @selectedImgNumber = 0

            @btnLeft = @splitter1.getFirst().addDiv "left-arrow"
            @btnLeft.html "<i class='fa fa-arrow-circle-left fa-3x imagestripbutton' aria-hidden='true'></i>"
            # @btnLeft.css "zIndex", "+1"
            @btnLeft.bind "click", ()=>
                @prevImg()
            # @btnLeft.move 0, 0, 36, 36

            @btnRight = @splitter1.getFirst().addDiv "right-arrow"
            # @btnRight.css "zIndex", "auto"
            @btnRight.html "<i class='fa fa-arrow-circle-right fa-3x imagestripbutton' aria-hidden='true'></i>"
            @btnRight.bind "click", ()=>
                @nextImg()
            # @btnRight.move 0, 0, 36, 36

            @splitter1.resetSize()


    ##
    ## function to change width and height of the view when it is resized
    ##
    onResize: (w, h) =>
        super(w,h)
        true

    setData: (data)=>
        ##|
        ##|  Data is called upon initialize of the View, data values can be added optionally is setView call

        @createControls()
        # @renderThumbList()

        if data? and Array.isArray(data)
            @setImgData data
        else
            @setImgData []

        @selectedImgNumber = 0
        true

    ##
    ## function to set currently selected image's number
    ##
    setSelectedImgNumber: (number)=>
        if number? and 0 <= number and number < @getImageCount()
            @selectedImgNumber = number
            @resizeSelectedImage()
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
