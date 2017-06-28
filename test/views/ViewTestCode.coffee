class ViewTestCode extends View

    setCode: (newCode)=>

        newCode = "<pre><code class='language-javascript'>" + newCode + "</code></pre>"
        @txtCode.html newCode
        Prism.highlightAll()

