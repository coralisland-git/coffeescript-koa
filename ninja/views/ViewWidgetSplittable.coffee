class ViewWidgetSplittable extends View
	##
	## default function of class View that is necessary 
	##
	onSetupButtons: () =>

	##
	## dssefault function of class View
	##    
	setTitle: (title)=>

	getDependencyList: () =>
		return ["/vendor/split.js"]

	setData: (@optionData) =>

	show: (name) =>
		if name? 
			@gid = name
		else
			@gid = GlobalValueManager.NextGlobalID()
		@elHolder.find(".widgetsplittable-container").html "<div id='widgetsplittable#{@gid}' class='widgetsplittable' />"
		@wdtSplittable = new WidgetSplittable @elHolder.find("#widgetsplittable#{@gid}")
		@wdtSplittable.render(@optionData)
		true

	getWidget: () =>
		return @wdtSplittable

