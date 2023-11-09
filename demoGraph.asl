
Package p_BillingASL

Import p_BillingASL.Billing_ASL.*

/********************************************************  
   System definition
*********************************************************/

System Billing_App_ASL "BillingSystem (Application Level)" : Application: Application_Web 
[ isFinal description "Billing system "] 


DataAttributeType GeoPoint [description "GeoPoint attribute type (for geospatial data)"]
DataAttributeType GeoPolyline [description "GeoPolyline attribute type (for geospatial data)"]
DataAttributeType GeoPolygn [description "GeoPolygn attribute type (for geospatial data)"]
DataAttributeType GeoRaster [description "GeoRaster attribute type (for geospatial data)"]



DataEntity e_VAT "VAT Category" : Reference [  
  attribute VATCode "VAT Code" : DataEnumeration InvoiceStatusKind [constraints (PrimaryKey)]   
  attribute VATName "VAT Class Name" : String(30) [constraints (NotNull)]
  attribute VATValue "VAT Class Value" : Decimal(2.3) [constraints (NotNull)]
  constraints (Check (ck_VAT1 "(VATCode in ['R', 'S', 'N'])"))
  description "VAT Categories"]   

DataEntity e_Product "Product" : Master [
  attribute ID "Product ID" : Integer [constraints (PrimaryKey)]
  attribute Name "Name" : String(50) [constraints (multiplicity "1..2") description "Product Name"]
  attribute valueWithoutVAT "Price Without VAT" : Decimal(16.2) [constraints (NotNull) ]
  attribute valueWithVAT "Price With VAT" : Decimal(16.2) [constraints (NotNull Derived ("Self.valueWithoutVAT * (1 + Self.VATValue)") ) ]
  attribute VATCode "VAT Code" : Integer [constraints (NotNull ForeignKey (e_VAT defaultValue 'N' onDelete SET_DEFAULT) )]
  attribute VATValue "VAT Value" : Decimal(2.2) [constraints (NotNull Derived (e_VAT.VATValue) )]
  attribute size : DataEnumeration UserRoleKind
  attribute local: GeoPoint
  description "Products"]  

DataEntity e_Custo "Customer" : Master [ 
  attribute ID "Customer ID" : Integer [constraints (PrimaryKey)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute fiscalID "Fiscal ID" : String(12) [helpMessage "Customer's Fiscal Id" constraints (NotNull Unique) ]
  attribute BankID "Bank ID" : Regex [helpMessage "IBAN of customer's bank account" constraints (Check (ck_BankID "ValidBankID(BankID)"))] 
  attribute email "Email" : Email
  attribute phone "Phone #" : String(12) [constraints (NotNull)]
  attribute image "Image" : Image
  constraints ( Encrypted Check (ck_Customer1 "ValidFiscalID(fiscalID)") )
  description "Customers"]

DataEntity e_Customer "Customer" : Master [ 
  attribute discountRate "Discount Rate" : Decimal [defaultValue "20%" ]
  constraints (Encrypted)
  description "Customers"]

DataEntity e_CustomerVIP "CustomerVIP" : Master [ 
  attribute discountRate "Discount Rate" : Decimal [defaultValue "20%" ]
  constraints (Encrypted)
  description "Customers VIP"]

DataEntity e_Invoice "Invoice" : Document: Regular [
  attribute ID "Invoice ID" : Integer [constraints (PrimaryKey)]
  
  attribute dateCreation "Creation Date" : Date [defaultValue "today" constraints (NotNull)]
  attribute dateApproval "Approval Date" : Date
  attribute datePaid "Payment Date" : Date
  attribute dateDeleted "Delete Date" : Date
  attribute invoiceStatus "State" : DataEnumeration InvoiceStatusKind 
  attribute totalValueWithoutVAT "Total Value Without VAT" : Decimal(16.2) [constraints (NotNull)]
  attribute totalValueWithVAT "Total Value With VAT" : Decimal(16.2) [constraints (NotNull)] 
  description "Invoices"]

DataEntity e_InvoiceLine "InvoiceLine" : Document: Weak [
  attribute ID "InvoiceLine ID" : Integer [constraints (PrimaryKey)]
  attribute invoiceID "Invoice ID" : Integer [constraints (NotNull ForeignKey (e_Invoice onDelete CASCADE))]
  attribute order "InvoiceLine Order" : Integer [constraints (NotNull)]
  attribute productID "Product ID" : Integer [constraints (NotNull ForeignKey (e_Product onDelete PROTECT))]
  attribute valueWithoutVAT "Value Without VAT" : Decimal
  attribute valueWithVAT "Value With VAT" : Decimal 
  description "InvoiceLines"] 
 //yolo
DataEntity e_User "User" : Master [
  attribute ID "ID" : Integer [constraints (PrimaryKey)]
  attribute login "Login" : Regex [visualization "???999" constraints (NotNull Unique Check(validation "???999"))]
  attribute password "Password" : Regex [constraints (NotNull Encrypted)]
  attribute Name "Name" : Text [constraints (NotNull Encrypted)]
  attribute email "Email" : Email [constraints (Unique Encrypted)]
  attribute active "IsActive" : Boolean
  attribute userProfileID "User Profile" : Integer [constraints (NotNull ForeignKey (e_UserProfile onDelete PROTECT))]
  tag (name "tenant" value "true")
  description "Users"]

DataEntity e_UserProfile "UserProfile" : Parameter [   
  attribute ID "ID" : Integer [constraints (PrimaryKey)]
  attribute Name "Name" :  DataEnumeration UserRoleKind [constraints (NotNull)]
  attribute Description "Description" : Text ]
  
DataEntity e_ClosedInvoice "ClosedInvoice" : Transaction [
  attribute ID "Invoice ID" : Integer [constraints (PrimaryKey)]
  attribute customerID "Customer ID" : Integer [constraints (NotNull ForeignKey (e_Customer onDelete PROTECT))]
  attribute dateCreation "Creation Date" : Date [defaultValue "today" constraints (NotNull)]
  attribute dateApproval "Approval Date" : Date
  attribute datePaid "Payment Date" : Date
  attribute dateDeleted "Delete Date" : Date
  attribute totalValueWithoutVAT "Total Value Without VAT" : Decimal(16.2) [constraints (NotNull)]
  attribute totalValueWithVAT "Total Value With VAT" : Decimal(16.2) [constraints (NotNull) ]
  description "Closed Invoices, for Backup"]  



/********************************************************
   DataEntityCluster view
*********************************************************/
DataEntityCluster ec_VAT "VAT" : Reference [main e_User]
DataEntityCluster ec_User "Users" : Master [main e_User]
DataEntityCluster ec_Customer "Customers" : Master [main e_Customer description "ec_Customer" ]
DataEntityCluster ec_Product "Products" : Master [main e_Product uses e_VAT]
DataEntityCluster ec_Invoice "Invoices (Complex)" : Document  [
	main e_Invoice 
	child e_InvoiceLine [uses e_Product, e_VAT]
	uses e_Customer]
DataEntityCluster ec_Invoice_Simple "Invoices (Simple)" : Document [main e_Invoice uses e_Customer]


/********************************************************
   Actors view
*********************************************************/
Actor aU_Operator "Operator" :User [description "Operator manages Invoices and Customers"]
Actor aU_Manager "Manager" : User [ description "Manager approves Invoices, etc."]

/* General Customer Actions
// ActionType aCreate
// ActionType aRead
// ActionType aUpdate
// ActionType aDelete*/
ActionType aSearch   
ActionType aFilter
ActionType aPrint
ActionType aSend
ActionType aImport
ActionType aExport
ActionType aAnalyse
ActionType aReadFirst
ActionType aReadPrevious
ActionType aReadNext
ActionType aReadLast
ActionType aClose [description "Close the current Interaction (Form, Windows, Dialog, etc.)"]
ActionType aCancel [description "Cancel the current Interaction (Form, Windows, Dialog, etc.)"]
ActionType aConfirm [description "Confirm the current Interaction (Form, Windows, Dialog, etc.)"]

// Specific Customer Actions
ActionType aSend_Invoice [description "Send Invoice to Customer via email"]
ActionType aExport_Invoices [description "Export a selected set of Invoices to a previously defined format, e.g. xlsx, json, rtf."]
ActionType aPrint_Invoice [description "Print an Invoice according a previously defined template"]
ActionType aPrint_Invoices [description "Print a selected list of Invoices according a previously defined template"]
ActionType aReSubmit2Approval [description "Resubmit Invoice to Approval process"]
ActionType aConfirmPayment [description "Confirm the Invoice's payment"]
ActionType aApprove [description "Approve Invoice"]
ActionType aReject [description "Do not Approve Invoice"]
ActionType aPrint_Customer [description "Print Customer Profile"]



UseCase uc_1_ManageInvoices "Manage Invoices" : EntitiesManage [
  actorInitiates aU_Operator 
  dataEntity ec_Invoice
  actions aClose, aSearch, aFilter, aCreate, aRead, aSend_Invoice, aExport_Invoices, aPrint_Invoice, aPrint_Invoices  
  extensionPoints 	EPCreate, EPRead, EPUpdate, EPConfirmPayment, EPDelete, EPSendInvoices, EPExportInvoices, 
  					EPPrintInvoice, EPPrintInvoices
 ]

UseCase uc_1_2_UpdateInvoice "Update Invoice" : EntityUpdate [
	actorInitiates aU_Operator
	dataEntity ec_Invoice
	actions aUpdate, aReSubmit2Approval ]
	
	
UseCase uc_1_1_CreateInvoice "Create Invoice" : EntityCreate [
  actorInitiates aU_Operator
  dataEntity ec_Invoice_Simple 
  actions aCreate, aCancel, aCreate, aSearch, aDelete 
  extensionPoints EPCreateCustomer, EPReadCustomer
  
]

UseCase uc_2_ManageVATs "Manage VAT" : EntitiesManage [
	actorInitiates aU_Manager
	dataEntity ec_VAT
	actions aCreate, aRead, aUpdate, aDelete
]

UseCase uc_3_BrowseVATS "Browse VATS" : EntitiesMapShow [
	actorInitiates aU_Operator
	dataEntity ec_VAT
	actions aRead, aSearch, aFilter
]

Data d_VAT : e_VAT := 
   [[VATCode,	VATName, VATValue]
	[1, 	 "Standard", 23%	 ]
	[2, 	 "Reduced", 	13%	 ]
	[3, 	 "Special",	30%	 ]]


View demoView : UseCaseView [
    
    uc_1_1_CreateInvoice,
    uc_1_ManageInvoices,
     uc_1_2_UpdateInvoice
]


/**********************************************************************/
UIContainer uiCt_MainPage : Window [
component uiCo_TopMenu : Menu: Menu_Main [
	part p_optionHome "Home" :  Slot: Slot_MenuOption [ event ev_home "GoToHome" :Submit [navigationFlowTo uiCt_MainPage]]
	
	part p_e_VAT "e_VAT": Slot: Slot_MenuOption [ event ev_e_VAT "Go To e_VAT" :Submit [navigationFlowTo uiCt_MainPage]]
	part p_e_Product "e_Product": Slot: Slot_MenuOption [ event ev_e_Product "Go To e_Product" :Submit [navigationFlowTo uiCt_MainPage]]
	part p_e_Customer "e_Customer": Slot: Slot_MenuOption [ event ev_e_Customer "Go To e_Customer" :Submit [navigationFlowTo uiCt_MainPage]]
	part p_e_CustomerAddress "e_CustomerAddress": Slot: Slot_MenuOption [ event ev_e_CustomerAddress "Go To e_CustomerAddress" :Submit [navigationFlowTo uiCt_MainPage]]
	part p_e_CustomerVIP "e_CustomerVIP": Slot: Slot_MenuOption [ event ev_e_CustomerVIP "Go To e_CustomerVIP" :Submit [navigationFlowTo uiCt_MainPage]]
	part p_e_Invoice "e_Invoice": Slot: Slot_MenuOption [ event ev_e_Invoice "Go To e_Invoice" :Submit [navigationFlowTo uiCt_MainPage]]
	part p_e_InvoiceLine "e_InvoiceLine": Slot: Slot_MenuOption [ event ev_e_InvoiceLine "Go To e_InvoiceLine" :Submit [navigationFlowTo uiCt_MainPage]]
]]


//UI FOR CREATE
UIContainer uiEditor_VAT : Window: Window_Modal [
component uiCo_EditVAT : Form : Form_Simple [

	part VATCode_Label : Field: Field_Output : WFC_Label [Text defaultValue "VATCode"  tag (name "AlignText" value "Left") tag (name "Multiline" value "False")]
	part VATCode_TextEditor : Field: Field_Input  : WFC_Text [Text defaultValue "Insert here"]	

	part VATName_Label : Field: Field_Output : WFC_Label [Text defaultValue "VATName" tag (name "AlignText" value "Left") tag (name "Multiline" value "False")]
	part VATName_TextEditor : Field: Field_Input : WFC_Text [Text defaultValue "Insert here"]	

	part VATValue_Label : Field: Field_Output : WFC_Label [Text defaultValue "VATValue" tag (name "AlignText" value "Left") tag (name "Multiline" value "False")]
	part VATValue_TextEditor : Field: Field_Input : WFC_Text [Text defaultValue "Insert here"]	

	event ev_Confirm : Submit: Submit_Ok  [navigationFlowTo uiEditor_VAT ]
	event ev_Cancel  : Submit: Submit_Cancel [navigationFlowTo uiEditor_VAT]	
]]

//UI FOR UPDATE
UIContainer uiCT_VATEditor : Window: Window_Modal [
				
		component uiCo_EditVAT : Form : Form_Simple [
		
			part VATCodeLabel : Field: Field_Output [Text defaultValue "VATCode"]
			part VATCodeInsertor : Field: Field_Input [Text defaultValue ""]	
					
			part VATNameLabel : Field: Field_Output [Text defaultValue "VATName"]
			part VATNameInsertor : Field: Field_Input [Text defaultValue ""]	
					
			part VATValueLabel : Field: Field_Output [Text defaultValue "VATValue"]
			part VATValueInsertor : Field: Field_Input [Text defaultValue ""]	
						
			event ev_confirme_VAT : Submit: Submit_Ok [navigationFlowTo VATCodeInsertor]
			event ev_cancele_VAT  : Submit: Submit_Cancel [navigationFlowTo VATCodeInsertor]	
		
		]
]		
							
//UI FOR DELETE INDIVIDUAL
UIContainer uiCt_DeleteBox : Window : Window_Modal [
		component uiCo_DeleteWarning : Details  [ 
		 	
		 	event ev_confirmdelete : Submit [navigationFlowTo ev_canceldelete]
		 	event ev_canceldelete : Submit [navigationFlowTo ev_canceldelete]
		 		
		]
]

UIContainer uiCt_DeleteConfirmation : Window : Window_Modal [
	component uiCo_DeleteWarning : Details  [ 
	 	part Message: Field: Field_Output [Text defaultValue "e_VAT Deleted" ]		 
	]

]



//UI FOR DELETE VARIOS  CHECKBOX
//TO DO




//UI FOR READ	
UIContainer uiCt_Details : Window : Window_Modal [
	
	UIContainer uiCT_e_VATEditor : Window : Window_Modal [
			
		component uiCo_EditVAT : Form : Form_Simple [
			part VATCodeLabel : Field: Field_Output [Text defaultValue "VATCode" ]
			part VATNameLabel : Field: Field_Output [Text defaultValue "VATName"]
			part VATValueLabel : Field: Field_Output [Text defaultValue "VATValue"]
		]

		component uiCo_e_VATButtons : Details [
			event ev_begine_VAT : Submit [navigationFlowTo ev_begine_VAT]
			event ev_previouse_VAT : Submit [navigationFlowTo ev_previouse_VAT]
			event ev_nextVate_VAT : Submit [navigationFlowTo ev_nextVate_VAT]
			event ev_endVate_VAT : Submit [navigationFlowTo ev_endVate_VAT]
	 	]
	]

]
	

/**********************************************************************/
/*UIContainer aligned with uc_3_BrowseVATS

//UI GERAL 

UIContainer uiCt_Page : Window [

	//TO DO
]

//UI FOR READ	*/
UIContainer uiCt_Details : Window : Window_Modal [
			
  UIContainer uiCT_e_VATEditor : Window: Window_Modal [
			
		component uiCo_Edite_VAT : Form : Form_Simple [
			part VATCodeLabel : Field: Field_Output [Text defaultValue "VATCode"]
			part VATNameLabel : Field: Field_Output [Text defaultValue "VATName"]
			part VATValueLabel : Field: Field_Output [Text defaultValue "VATValue"]
		]
		
	component uiCo_e_VATButtons : Details [
		event ev_begine_VAT : Submit [navigationFlowTo ev_begine_VAT]
		event ev_previouse_VAT : Submit [navigationFlowTo ev_previouse_VAT]
		event ev_nextVate_VAT : Submit [navigationFlowTo ev_nextVate_VAT]
		event ev_endVate_VAT : Submit [navigationFlowTo ev_endVate_VAT]
 	]
  ]
]
	
							
	//UI FOR SEARCH
	component uiCo_Search: Details [
		part p_searche_VAT: Field: Field_Input [Text defaultValue "Search  e_VAT"] 
	]	
	
	





