
class ViewTestIcons extends View

    onShowScreen: ()=>

        $.get "/vendor/icons.json", (data)=>
            console.log "ICONS:", data

            html = ""
            for icon in data

                prefix = "si"
                if /fa-/.test icon then prefix = "fa"

                str = "<div class='fa-hover col-sm-3 icon_example'>
                        <div class='icon_image'><i class='#{prefix} #{icon}'></i></div>
                        <div class='icon_name' onClick='doCopyIcon(this);'> #{icon} </div>
                    </div>"

                html += str

            @el.html html
