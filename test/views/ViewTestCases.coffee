class ViewTestCases extends View

    onShowScreen: (newWidth, newHeight)=>

        ##|
        ##|  Check for a hash value and load a test page
        page = ""
        if document.location.search?
            m = document.location.search.match /page=(.*)/
            if m? and m[1] then page = m[1]
                #

        window.elTestCase = $("#testCases")

        if page? and page.length
            $("body").append "<script src='/js/" + page + ".js' /></script>"