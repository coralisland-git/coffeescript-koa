globalPopupTooltipWindow = null

class PopupTooltip

    constructor: (w, h)->

        @gid = GlobalValueManager.NextGlobalID()

        ##|
        ##|  Create the popup window the first time
        if globalPopupTooltipWindow == null

            globalPopupTooltipWindow = $ "<div>",
                class:  "popupWindowTooltip"
                id:     "popupWindowTooltip"
