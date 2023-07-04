Package bil

/********************************************************
    System definition 
*********************************************************/

System BIL "" : Application : Application_Web

/********************************************************
    DataEntities view
*********************************************************/
		
DataEntity e_PRODU "Product" : Master [
	attribute CODPRODU "Product ID" : Integer(8) [constraints ( PrimaryKey )]
	attribute NAME "Name" : Text(50) 
	attribute VALUEWIT "Price Without VAT" : Decimal(16.2) 
	attribute VALUEWI0 "Price With VAT" : Decimal(16.2) 
	attribute VATVALUE "VAT Value" : Decimal(2.2) 
	attribute LOCAL "" : Text(50) 
	description "Product"
]


Actor a_Admin "TechnicalAdmin" : User []
Actor a_Manager "Manager" : User [description "Approve Invoices, etc."]
Actor a_Operator "Operator" : User [description "Manage Invoices and Customers"]
Actor a_ERP "ERP" : ExternalSystem [description "Receive info of paid invoices"] 




