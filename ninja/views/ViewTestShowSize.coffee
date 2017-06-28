class ViewTestShowSize extends View

    onShowScreen: ()=>

        @el.css "border", "1px dashed blue"

    onResize: (w, h)=>
        super(w, h)

        str = "<table class='infoTable'>"
        str += "<tr><td> onResize w=</td><td> #{w} </td> <td align=right> h= </td> <td> #{h} </td></tr>"
        str += "<tr><td> internal w=</td><td> #{@width()} </td> <td align=right> h= </td> <td> #{@height()} </td></tr>"
        str += "<tr><td> outer w=</td><td> #{@outerWidth()} </td> <td align=right> h= </td> <td> #{@outerHeight()} </td></tr>"
        str += "</table>"
        @el.html str


