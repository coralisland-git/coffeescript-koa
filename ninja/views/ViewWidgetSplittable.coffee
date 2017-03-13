class ViewWidgetSplittable extends View
	##
	## default function of class View that is necessary 
	##
	onSetupButtons: () =>

	##
	## dssefault function of class View
	##    
	setTitle: (title)=>

    setSize: (w, h)=>
    	if w > 0
        	@elHolder.width(w)
        if h > 0
        	@elHolder.height(h)

	getDependencyList: () =>
		return ["/vendor/split.min.js"]

	setData: (@optionData) =>

	show: (name) =>
		if name? 
			@gid = name
		else
			@gid = GlobalValueManager.NextGlobalID()
	
		@elHolder.find(".widgetsplittable-container").attr "id","widgetsplittable#{@gid}"
		@wdtSplittable = new WidgetSplittable @elHolder.find("#widgetsplittable#{@gid}")
		@wdtSplittable.render(@optionData)
		true

	getWidget: () =>
		return @wdtSplittable

