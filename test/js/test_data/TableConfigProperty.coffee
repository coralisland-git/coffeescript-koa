TableConfigProperty = []

TableConfigProperty.push
	name       : 'RR ID'
	source     : 'id'
	visible    : true
	hideable   : true
	editable   : false
	type       : 'int'
	required   : true

TableConfigProperty.push
	name       : 'MLS ID'
	source     : 'mls_id'
	visible    : false
	hideable   : false
	editable   : false
	type       : 'int'
	required   : true

TableConfigProperty.push
	name       : 'RETS Server Unique ID'
	source     : 'sys_id'
	visible    : false
	hideable   : false
	editable   : false
	limit      : 32
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Create Date'
	source     : 'create_date'
	visible    : false
	hideable   : true
	editable   : false
	type       : 'datetime'
	required   : false

TableConfigProperty.push
	name       : 'Metro Area'
	source     : 'metro_area'
	visible    : true
	hideable   : true
	editable   : false
	limit      : 32
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Display Address'
	source     : 'display_name'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 200
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Sale Type'
	source     : 'sale_type'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['Not set','Conventional','New Construction','Short Sale','REO','FNMA','HUD','Relocation','FreddieMac','Hubzu','Off Market','Auction','VA','Estate','None','Investor','Bankruptcy','Other','Subject to court approval',
		'ADD', 'CAPC-1', 'CAPC-2', 'Bulk-1', 'Bulk-2']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Workflow'
	source     : 'workflow'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 32
	type       : 'enum'
	options    : ["Active","Active- Off Market","Active- Ready","Active- UCNS","Active- UCS","Active- UCS Off Market","Active- Vetted","Active- Watch","Admin- INSPECTED","Admin- Pre-Inspect","Admin- Write Issue","Admin- WRITE OFFER","Client Rejected","Closed","Expired","Not set","Offer- AcceptBySeller","Offer- ACCEPTED","Offer- AcceptedBkUp","Offer- Not Won","Offer- Rejected","Offer- Submitted","PURCHASED","Remove","Terminated","Withdrawn","Sold"]
	required   : true

TableConfigProperty.push
	name       : 'Rental'
	source     : 'is_rental'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'boolean'
	required   : false

TableConfigProperty.push
	name       : 'List Date'
	source     : 'list_date'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'datetime'
	required   : false

TableConfigProperty.push
	name       : 'List Price'
	source     : 'list_price'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Close Date'
	source     : 'close_date'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'datetime'
	required   : false

TableConfigProperty.push
	name       : 'Close Price'
	source     : 'close_price'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Listing Status'
	source     : 'listing_status'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['Closed','Under Contract-Show','Under Contract-No Show','Active','Sold','Due Diligence Period','Pending','Pending AB','Short Sale Contingent','Application Received','Withdrawn','Expired','Contingent','Temp.Off Market']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Property Type'
	source     : 'property_type'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['House','Unknown Rental','Condo/Townhouse','Manufactured','Other','Apartment','Office','Expired','Detached','Industrial/Warehouse','Residential Lot','Farm']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Address'
	source     : 'address'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 96
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'City'
	source     : 'city'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 64
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'State'
	source     : 'state'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 32
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Zipcode'
	source     : 'zipcode'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 12
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'County'
	source     : 'county'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 32
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Listing Type'
	source     : 'listing_type'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 64
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Num Bathrooms'
	source     : 'num_bathrooms'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'decimal'
	required   : false

TableConfigProperty.push
	name       : 'Num Bedrooms'
	source     : 'num_bedrooms'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'decimal'
	required   : false

TableConfigProperty.push
	name       : 'Num Stories'
	source     : 'num_stories'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'decimal'
	required   : false

TableConfigProperty.push
	name       : 'Total Sqft (Vetted)'
	source     : 'total_sqft'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'int'
	required   : false

TableConfigProperty.push
	name       : 'Total Sqft Estimated'
	source     : 'total_sqft_est'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'int'
	required   : false

TableConfigProperty.push
	name       : 'Subdivision'
	source     : 'subdivision'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 96
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Year Built'
	source     : 'year_built'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'int'
	options    : "####"
	required   : false

TableConfigProperty.push
	name       : 'Lot Size Estimated'
	source     : 'lot_size'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 64
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Sewer'
	source     : 'sewer'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 64
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Parking'
	source     : 'parking'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 196
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Parcel Id'
	source     : 'parcel_id'
	visible    : false
	hideable   : false
	editable   : false
	limit      : 32
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Special Circumstances'
	source     : 'special_circumstances'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 196
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Construction Status'
	source     : 'construction_status'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['None','Under Construction','Complete','Proposed','Yes - Unknown Status']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Flood Zone'
	source     : 'flood_zone'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['Not Specified','Not in Flood Zone','Partial','Flood Fringe','Flood Plain','Flood Way','Wetlands']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Basement'
	source     : 'basement'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['Unknown','Full','Partial','Split','Other','None']
	type       : 'enum'
	required   : true

TableConfigProperty.push
	name       : 'Seller Concession Amt'
	source     : 'seller_concession_amt'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Hoa Company Name'
	source     : 'hoa_company_name'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 100
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Hoa Annual Amount'
	source     : 'hoa_annual_amount'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Pool'
	source     : 'pool'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['Unknown','Yes','No','In-Ground Pool','Above Ground','Indoor Pool','Community']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Rate (Vetted)'
	source     : 'rate'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 12
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Rate Estimate'
	source     : 'rate_estimate'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 12
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Target Offer Date'
	source     : 'offer_date'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'datetime'
	required   : false

TableConfigProperty.push
	name       : 'Target Offer Price'
	source     : 'offer_price'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Rehab Adjust (Formula)'
	source     : 'rehab_adjust'
	visible    : true
	hideable   : true
	editable   : false
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Rehab Price (Vetted)'
	source     : 'rehab_price'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Rehab Actual (From Bid)'
	source     : 'rehab_actual'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Other Closing Costs'
	source     : 'other_closing_costs'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Rent (Vetted)'
	source     : 'rent'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Rent Estimate'
	source     : 'rent_estimate'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Market Value (Vetted)'
	source     : 'market_value'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Market Value Estimated'
	source     : 'market_value_estimated'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Tax Value (Vetted)'
	source     : 'tax_value'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Tax Value Estimated'
	source     : 'tax_value_estimated'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'HOA Yearly (Vetted)'
	source     : 'hoa_yearly'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'HOA Yearly Estimate'
	source     : 'hoa_yearly_estimate'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Prop Tax/Yr (Vetted)'
	source     : 'property_tax_paid'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false
TableConfigProperty.push
	name       : 'Prop Tax/Yr Estimate'
	source     : 'property_tax_paid_estimate'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Prop Tax/Yr City (Vetted)'
	source     : 'property_tax_paid_city'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Listing Office'
	source     : 'listing_office'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 128
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Listing Agent'
	source     : 'listing_agent'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 128
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Listing Contact'
	source     : 'listing_contact'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 128
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Listing Office Phone'
	source     : 'listing_office_phone'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 128
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Other Closing Fee Contrib'
	source     : 'other_closing_feecontribute'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Commission Percent'
	source     : 'commission_percent'
	visible    : true
	hideable   : true
	editable   : true
	type       : 'money'
	required   : false

TableConfigProperty.push
	name       : 'Workflow Section'
	source     : 'workflow_section'
	visible    : true
	hideable   : true
	hideable   : true
	editable   : true
	options    : ['Vetting','Escrow','Construction','Leasing']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Workflow Type'
	source     : 'workflow_type'
	visible    : true
	hideable   : true
	editable   : true
	options    : ['Not Set','Vetting','Escrow','Purchased','Watching','Rejected','Closed']
	type       : 'enum'
	required   : false

TableConfigProperty.push
	name       : 'Deed Book'
	source     : 'deed_book'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 20
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Deed Page'
	source     : 'deed_page'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 20
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Plat Book'
	source     : 'plat_book'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 20
	type       : 'text'
	required   : false

TableConfigProperty.push
	name       : 'Plat Page'
	source     : 'plat_page'
	visible    : true
	hideable   : true
	editable   : true
	limit      : 20
	type       : 'text'
	required   : false

$ ->

	##|
	##| Configure the global map
	root.DataMap.setDataTypes "property", TableConfigProperty


