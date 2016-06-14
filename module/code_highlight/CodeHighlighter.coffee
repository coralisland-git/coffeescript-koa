class CodeHighlighter

    ## -------------------------------------------------------------------------------------------------------------
    ## Reformat xml text to a pretty version of that text
    ##
    @utilFormatXML: (xml) ->

        formatted = ""
        reg = /(>)(<)(\/*)/g

        xml = replace reg, '$1\n$2$3'
        pad = 0
        lines = xml.split '\n'
        for node in lines
            indent = 0
            if node.match(/.+<\/\w[^>]*>$/)
                indent = 0
            else if node.match /^<\/\w/
                if pad != 0
                    pad -= 1
            else if node.match /^<\w[^>]*[^\/]>.*$/
                indent = 1
            else
                indent = 0

            padding = ''
            padding += " " while padding.length < (pad * 2)

            formatted += padding + node + '\r\n';
            pad += indent;

        return formatted;