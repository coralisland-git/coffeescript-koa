$ ->

	testHtml = '''
		<div id='testBoard' class='grid'>

			<div class='gridItem' data-width='2' data-height='1' data-row="1">
				<div class='title'> Testing title </div>
				<div class='content' id='testContent1'> Test content <div>
			</div>

			<div class='gridItem' data-width='1' data-height='1' data-row="1">
				<div class='title'> Testing 1 </div>
				<div class='content' id='testContent2'> Test content <div>
			</div>

			<div class='gridItem' data-width='1' data-height='1' data-row="2">
				<div class='title'> Testing 2 </div>
				<div class='content'> Test content <div>
			</div>

		<div>

	'''

	increaseTest1 = ()->

		content = $("#testContent2").html()
		content += "<br>" + (new Date())
		$("#testContent2").html(content)
		setTimeout increaseTest1, Math.ceil(Math.random()*2000)

	$("#testCase").html testHtml

	gridBoard = new GridBoard "testBoard"

	setTimeout ()=>
		increaseTest1()
	, 5000


