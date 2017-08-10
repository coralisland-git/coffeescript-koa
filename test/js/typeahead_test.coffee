$ ->
	addTestButton "Loading Zipcodes", "Open", () ->
		loadZipcodes()
		.then ()->
			console.log "Zipcodes data loaded"
		.catch () ->
			console.error "error in loading Zipcodes data"

	addTestButton "Typeahead with Tables", "Open", ()->
		template = '''
			<div style="position: absolute; top: 0; left:0px; right:0; bottom: 0;"
				<br>
				<header id="header-navbar">
					<ul class="nav-header pull-right">
						<li style="width:170px;" class="js-header-search">
							<div id="teamInput" class="form-control" style="width:100%;"></div>
						</li><li style="" class="js-header-search">
							<div style="width: 200px; margin-right: 24px;">
								<input id="searchInput" name="searchInput" type="text" placeholder="Search..." class="form-control">
							</div>
						</li>
					</ul>
				</header>
				<p>

				<div style="padding:30px">

					<br>
					<div class='testInput1'>
						<input name='testCity' id='testCity' width='150'>
					</div>
					<br>

					<div id='ptestMenu1' style='width: 140px;'></div>
					<br>

					<div id='ptestMenu2' style='width: 140px;'></div>
					<br>

					<div id='ptestMenu3' style='width: 260px;'></div>
					<br>

				</div>
			</div>
		'''

		loadZipcodes()
		.then ()->

			result = DataMap.addColumn "test",
				name   : "options"
				source : "options"

			result = DataMap.addColumn "test",
				name   : "options2"
				source : "options2"

			div = addHolder().addDiv "testPage"
			div.html template

			result = {"_id":"577abce5ec795af72c029f44","id":4,"company_id":1,"username":"jim","password":"0c5cc4d1769541e5a4b7c5cd94bee94f","create_date":"2014-03-18T04:00:00.000Z","last_login":"2016-07-03T00:33:06.000Z","name":"Jim Newgent","phone":"480-307-3953","email":"jnewgent@southcrestrealty.com","roles":["Admin","Company Admin","Company User","Phase Approval"],"active":true,"access":["EscrowEdit"],"regions":[""],"_lastModified":"2016-08-04T19:16:46.743Z","is_company_admin":true,"company":{"_id":"577abaafec795af72c029f40","id":1,"name":"Southcrest Realty","address":"8015 Kenton Circle, Huntersville NC 28078","phone":"704-746-9000","active":true,"google_docs":{"user":"southcrestportal@gmail.com","pass":"testing555"},"available_tags":[" Active- Inspected"," Active- Off Market"," Active- Ready"," Active- UCNS"," Active- UCS"," Active- Vetted"," Active- Watch"," Admin- Inspect SCHD"," Admin- Pre-Inspect"," Admin- Re-WRITE"," Admin- WRITE OFFER"," Admin- Write Issue"," Client Rejected"," Closed"," Expired"," Not set"," Offer- ACCEPTED"," Offer- AcceptBySeller"," Offer- AcceptedBkUp"," Offer- Not Won"," Offer- Rejected"," Offer- Submitted"," PURCHASED"," Remove"," Terminated"," Withdrawn","Active"],"sale_types":["Auction","Conventional","Estate","FNMA","FreddieMac","HUD","Hubzu","Investor","NEW Construction","Off Market","REO","Relocation","Sale-Institution-Flip","Sale-Institution-Rehabbed","Sale-Retail","Short Sale"],"escrow_companies":["Confirmation Needed","Family/Friend Occupied","Not Set","Other/See Notes","Owner Occupied","Tenant Occupied","Vacant"],"escrow_attorney_options":["Costner","Hutchens","John T Cook"],"_lastModified":"2016-08-06T15:48:52.854Z","client":{"1":{"id":1,"client_name":"CAH","client_legal_name":"Colony","metro_area":["Raleigh"],"priority_order":1,"ny_a_plus":4.75,"ny_a":5,"ny_a_minus":5.25,"ny_b_plus":5.5,"ny_b":5.6,"ny_b_minus":6,"ny_c_plus":0,"ny_c":0,"ny_c_minus":0,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.055)*.925","formula_maint_fee":"(RENT * 0.925 * 0.08)","formula_insurance":"((RENT*.75) / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5) + (IF(YEAR_BUILT < 2001, 1000,0))","formula_acq_basis":"(OFFER_PRICE * 1.005) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.75)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.03, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.04) + 85), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 65+10","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.045) / ACQ_BASIS"},"2":{"id":2,"client_name":"CSH","client_legal_name":"Colony","metro_area":["Charlotte"],"priority_order":1,"ny_a_plus":4.8,"ny_a":5,"ny_a_minus":5.25,"ny_b_plus":5.5,"ny_b":5.6,"ny_b_minus":6,"ny_c_plus":0,"ny_c":0,"ny_c_minus":0,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.055)*.925","formula_maint_fee":"(RENT * 0.925 * 0.08)","formula_insurance":"((RENT*.75) / 3 / 12) + (0.925 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5) + (IF(YEAR_BUILT < 2001, 1000,0))","formula_acq_basis":"(OFFER_PRICE * 1.005) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.75)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.03, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.04) + 85), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 65 + 10","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.045) / ACQ_BASIS"},"3":{"id":3,"client_name":"CSH","client_legal_name":"Colony","metro_area":["Nashville"],"priority_order":1,"ny_a_plus":4.9,"ny_a":5,"ny_a_minus":5.25,"ny_b_plus":5.5,"ny_b":5.75,"ny_b_minus":6,"ny_c_plus":0,"ny_c":0,"ny_c_minus":0,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.06)*.925","formula_maint_fee":"(RENT * 0.925 * 0.08)","formula_insurance":"((RENT*.75) / 3 / 12) + (0.925 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5) + (IF(YEAR_BUILT < 2001, 1000,0))","formula_acq_basis":"(OFFER_PRICE * 1.005) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.75)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.03, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 85), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 65 + 10","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.045) / ACQ_BASIS"},"4":{"id":4,"client_name":"RRCP-1","client_legal_name":"River Rock Capital","metro_area":["Charlotte","Raleigh","Triad"],"priority_order":2,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 850, 850, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * 0.012","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"5":{"id":5,"client_name":"RRCP-1","client_legal_name":"River Rock Capital","metro_area":["Raleigh"],"priority_order":3,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6,"ny_b":6,"ny_b_minus":6,"ny_c_plus":6.5,"ny_c":6.5,"ny_c_minus":7,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(RENT * 0.93 * 0.08)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 850, 850, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.02, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 110), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"6":{"id":6,"client_name":"RRCP-1","client_legal_name":"River Rock Capital","metro_area":["Nashville"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6,"ny_b":6,"ny_b_minus":6,"ny_c_plus":6.5,"ny_c":6.5,"ny_c_minus":7,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(RENT * 0.93 * 0.08)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 850, 850, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.02, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 110), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"8":{"id":8,"client_name":"IH-5","client_legal_name":"Invitation Homes","metro_area":["Triad"],"priority_order":8,"ny_a_plus":5,"ny_a":5,"ny_a_minus":5,"ny_b_plus":5,"ny_b":5,"ny_b_minus":5,"ny_c_plus":5,"ny_c":5,"ny_c_minus":null,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(RENT * 0.93 * 0.08)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1 - (YEAR_BUILT / 2020)) * 100) * (SQFT * 7.00) * 1.0000","formula_acq_basis":"(OFFER_PRICE * 1.005) + REHAB_PRICE + OTHER_CLOSING_COSTS + RENT","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.02, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 110), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"9":{"id":9,"client_name":"RRCP-1","client_legal_name":"River Rock Capital","metro_area":["Columbia","Columbus"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(RENT * 0.93 * 0.08)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 850, 850, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.02, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 110), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"10":{"id":10,"client_name":"643-C","client_legal_name":"643 Capital","metro_area":["Charlotte"],"priority_order":50,"ny_a_plus":5.8,"ny_a":6,"ny_a_minus":6.2,"ny_b_plus":6.5,"ny_b":6.5,"ny_b_minus":6.5,"ny_c_plus":6.5,"ny_c":6.5,"ny_c_minus":7,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(RENT * 0.93 * 0.08)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1 - (YEAR_BUILT / 2020)) * 100) * (SQFT * 7.00) * 1.0000","formula_acq_basis":"(OFFER_PRICE * 1.005) + REHAB_PRICE + OTHER_CLOSING_COSTS + RENT","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.02, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 110), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"11":{"id":11,"client_name":"Blue","client_legal_name":"Blue Mountain Homes","metro_area":["Charlotte","Raleigh","Nashville","Triad","Columbia","Tampa-Orlando","Atlanta","Columbus"],"priority_order":40,"ny_a_plus":16,"ny_a":16,"ny_a_minus":16,"ny_b_plus":16,"ny_b":16,"ny_b_minus":16,"ny_c_plus":0,"ny_c":0,"ny_c_minus":0,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(RENT * 0.93 * 0.08)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.03 < 3000, 3000, OFFER_PRICE * 1.03)) + REHAB_PRICE + OTHER_CLOSING_COSTS ","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.02,  IF(YEAR_BUILT > 2009, 0.025, IF(YEAR_BUILT > 1992, 0.3, 0.4)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 110), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"12":{"id":12,"client_name":"RRCP-1","client_legal_name":"River Rock Capital","metro_area":["Atlanta"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(RENT * 0.93 * 0.08)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 850, 850, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.03, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 210), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"13":{"id":13,"client_name":"RRCP-I","client_legal_name":"River Rock Capital","metro_area":["Tampa-Orlando"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"14":{"id":14,"client_name":"WR-CLT","client_legal_name":"Window Rock","metro_area":["Charlotte"],"priority_order":55,"ny_a_plus":15,"ny_a":15,"ny_a_minus":15,"ny_b_plus":15,"ny_b":15,"ny_b_minus":15,"ny_c_plus":15,"ny_c":15,"ny_c_minus":16,"formula_turn_cost":"(RENT * 1.5 / 3 / 12)","formula_mangement_cost":"(RENT * 0.07)","formula_maint_fee":"(IF(LIST_PRICE > 120000,.0025,IF(LIST_PRICE>90000,.0050, IF(LIST_PRICE>50000,.01,.015))) + IF(YEAR_BUILT>2014,.02, IF(YEAR_BUILT>2008,.03, IF(YEAR_BUILT>1991,.035, .04)))) * (RENT * .93)","formula_insurance":"(RENT / 3 / 12) + (0.93 * RENT * ADJUST_FOR_YEAR)","formula_rehab":"(SQFT*6)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 850, 850, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * 0.012","formula_age_multiplier":"IF(NEWCON, 0.03, IF(YEAR_BUILT < 1995, 0.05, 0.04))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.0328385656114541) + 110), 350)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12) + 60 + 20","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"18":{"id":18,"client_name":"RRCP-II","client_legal_name":"River Rock Capital","metro_area":["Tampa-Orlando"],"priority_order":11,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"19":{"id":19,"client_name":"WR-TOS","client_legal_name":"Window Rock","metro_area":["Tampa-Orlando"],"priority_order":7,"ny_a_plus":15,"ny_a":15,"ny_a_minus":15,"ny_b_plus":15,"ny_b":15,"ny_b_minus":15,"ny_c_plus":15,"ny_c":15,"ny_c_minus":16,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"SQFT * 6","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"20":{"id":20,"client_name":"WR-ATL","client_legal_name":"Window Rock","metro_area":["Atlanta"],"priority_order":4,"ny_a_plus":15,"ny_a":15,"ny_a_minus":15,"ny_b_plus":15,"ny_b":15,"ny_b_minus":15,"ny_c_plus":15,"ny_c":15,"ny_c_minus":16,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"SQFT * 6","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * 0.011","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"21":{"id":21,"client_name":"RRCP-I","client_legal_name":"River Rock Capital","metro_area":["Chicago"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"22":{"id":22,"client_name":"RRCP-I","client_legal_name":"River Rock Capital","metro_area":["FL-WPB"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"23":{"id":23,"client_name":"RRCP-I","client_legal_name":"River Rock Capital","metro_area":["FL-Miami"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"24":{"id":24,"client_name":"RRCP-I","client_legal_name":"River Rock Capital","metro_area":["BVb-0216"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"25":{"id":25,"client_name":"RRCP-I","client_legal_name":"River Rock Capital","metro_area":["BV628jn-0316"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"},"26":{"id":26,"client_name":"RRCP-I","client_legal_name":"River Rock Capital","metro_area":["OT3-0516"],"priority_order":10,"ny_a_plus":5.5,"ny_a":5.75,"ny_a_minus":6,"ny_b_plus":6.25,"ny_b":6.5,"ny_b_minus":6.75,"ny_c_plus":7,"ny_c":7.25,"ny_c_minus":7.5,"formula_turn_cost":"IF(YEARLY_RENT * .04 > 500, YEARLY_RENT * .04, 500)/12","formula_mangement_cost":"(RENT * 0.93 * 0.08)","formula_maint_fee":"(((IF(YEAR_BUILT > 2013, 0.02,  IF(YEAR_BUILT > 2007, 0.030, IF(YEAR_BUILT > 1992, 0.035, 0.04)))) + IF(LIST_PRICE > 160000,0, IF(LIST_PRICE > 120000, .0025, IF(LIST_PRICE > 90000,.0075, IF(LIST_PRICE > 50000,.01,.015))))) * IF(RENT>0,RENT,LIST_PRICE *.08/12)) ","formula_insurance":"(YEARLY_RENT * .01 * .93)","formula_rehab":"((1-(YEAR_BUILT/2030))*(100-1-(YEAR_BUILT/2030)))*(SQFT*5)","formula_acq_basis":"(IF(OFFER_PRICE * 1.006 < 950, 950, OFFER_PRICE * 1.006)) + REHAB_PRICE + OTHER_CLOSING_COSTS + (RENT*.5)","formula_tax_paid_estimate":"TAX_VALUE * (1.1/2)","formula_age_multiplier":"IF(NEWCON, 0.03,  IF(YEAR_BUILT > 2009, 0.040, IF(YEAR_BUILT > 1992, 0.045, 0.050))) + IF(LIST_PRICE > 120000,0, IF(LIST_PRICE > 90000, .0025, IF(LIST_PRICE > 50000,.005,.01)))","formula_adjust_sqft":"IF(SQFT > 0, ((SQFT * 0.2) + 100), 450)+500","formula_adjust_sqft_monthly":"(SQFT_ADJUSTMENT / 12)","formula_total_adjustments":"(TOTAL_TAX_PAID_MONTHLY + TOTAL_HOA_MONTHLY + (INSURANCE + MANAGEMENT_FEE + MAINT_FEE + TURN_COST) + SQFT_ADJUSTMENT_MONTHLY) * 12","formula_netyield":"((YEARLY_RENT - YEARLY_ADJUSTMENTS) * 1.02) / ACQ_BASIS"}}},"clients":[]}
			for idx, client of result.company.client
				client.metro_area_list = client.metro_area.join(", ")
				DataMap.addDataUpdateTable "team_list", client.id, client

			console.log "Creating dropdown for team on #teamInput"
			options =
				width:       300
				showHeaders: false
				allowEmpty : false
				render:      (val, row)=>
					return DataMap.getDataField("team_list", val, "client_name") + " in " + row.metro_area_list

			t = new TableDropdownMenu("#teamInput", "team_list", [ "id", "client_legal_name", "metro_area_list" ], options)
			t.on "change", (val)->
				console.log "TableDropdownMenu #1:", val

			t = new TypeaheadInput("#searchInput", "team_list", [ "client_legal_name"])
			t.on "change", (val)->
				console.log "search change:", val

			##|
			##|  Left side tests

			Words = [ "Apple", "Ball", "Bat", "Bath", "Car", "Dog", "Double", "Big Dog", "Bath House", "Ball Boy", "Dog Track", "Tracking", "Simple", "Zebra", "Cow","Horse","Pig","Snake"]
			DataMap.setDataCallback "test", "findAll", (condition)->
				console.log "data callback:", condition
				results = []
				results.push { id: word } for word in Words
				console.log "Return ", results
				return results

			DataMap.setDataCallback "test", "findFast", (id, subkey)->
				console.log "data callback test findFast id=#{id} subkey=#{subkey}"
				return id

			##|
			##|  Simple typeahead example

			t = new TypeaheadInput("#testCity", "test", [ "options" ])
			t.on "filter", (val, table)->

				max = Math.random() * 30
				Words = []
				for n in [0..max]
					Words.push val+" "+Math.ceil(Math.random()*2000)

				# table.updateRowData()
				# console.log "TypeaheadInput on filter:", val
				# console.log "Typeahead table:", table
				true

			t.on "change", (val)->
				console.log "TypeaheadInput #1:", val

			##|
			##|  Example 2 - Using zipcode data with a custom width and table headers

			t = new TableDropdownMenu("#ptestMenu1", "test", [ "options" ])
			t.on "change", (val)->
				console.log "TableDropdownMenu #1:", val

			options =
				width: 500
				showHeaders: true

			t = new TableDropdownMenu("#ptestMenu2", "zipcode", [ "id", "code", "city", "state" ], options)
			t.on "change", (val)->
				console.log "TableDropdownMenu #2:", val


			##|
			##|  Example 3 - Using the Zipcode data with a custom render function

			# options.render = (id, row)=>
			#     console.log "render[#{id}]", row
			#     return row.city + ", " + row.state + " - " + row.code

			# options.placeholder = "Select a location"

			# t = new TableDropdownMenu("#ptestMenu3", "zipcode", [ "id", "code", "city", "state" ], options)
			# t.on "change", (val)->
			#     console.log "TableDropdownMenu #2:", val

	addTestButton "Typeahead US Address Autocomplete", "Open", () ->
		divWrapper = addHolder().addDiv "", ""
		divWrapper.add "input", "autoAddress"
		divWrapper.add "input", "lat", "geolat", {type:'text'}
		divWrapper.add "input", "long", "geolong", {type:'text'}

		# instantiate the bloodhound suggestion engine
		locations = new Bloodhound({
		    datumTokenizer: (d) ->
		        return Bloodhound.tokenizers.whitespace(d.value)
		    ,
		    queryTokenizer: Bloodhound.tokenizers.whitespace,
		    remote: {
		        url: 'https://maps.googleapis.com/maps/api/geocode/json?address=%QUERY&components=country:GB&sensor=false&region=uk&key=AIzaSyAPOo6di3niunTz_huknmnW-PpTEc9vl_Q',
		        filter: (locations) -> 
		            return $.map(locations.results, (location) ->
		                return {
		                    value: location.formatted_address,
		                    geolat: location.geometry.location.lat,
		                    geolong: location.geometry.location.lng
		                }
		            )
		    }
		})

		# initialize the bloodhound suggestion engine
		locations.initialize();

		searchboxTypeahead = $('.autoAddress')
		geolatTypeahead = $('#geolat')
		geolongTypeahead = $('#geolong')
		#var locationverifyTypeahead = $('#locationverify');

		# Initialise typeahead 
		searchboxTypeahead.typeahead({
		    highlight: true,
		    autoselect: true
		}, {
		    name: 'value',
		    displayKey: 'value',
		    source: locations.ttAdapter()
		})

		# Set-up event handlers so that the ID is auto-populated when select label 
		searchboxItemSelectedHandler = (e, datum) ->
		    geolatTypeahead.val(datum.geolat)
		    geolongTypeahead.val(datum.geolong)
		    #locationverifyTypeahead.val(datum.value);

		searchboxTypeahead.on('typeahead:selected', searchboxItemSelectedHandler)
		searchboxTypeahead.on('typeahead:autocompleted', searchboxItemSelectedHandler)

	go()

