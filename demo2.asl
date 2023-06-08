Package bil

/********************************************************
    System definition 
*********************************************************/

System BIL "" : Application : Application_Web


/********************************************************
    DataEntities view
*********************************************************/


DataEntity e_PRODU "Products" : Master [
	attribute CODPRODU "Product IDs" : Integer(8) [constraints ( PrimaryKey )]
	attribute NAME "Name" : Text(50) 
	attribute VALUEWIT "Price Without VAT" : Decimal(16.2) 
	attribute VALUEWI0 "Price With VAT" : Decimal(16.2) 
	attribute VATVALUE "VAT Value" : Decimal(2.2) 
	attribute LOCAL "" : Text(50) 
	description "Product"
]
ddss