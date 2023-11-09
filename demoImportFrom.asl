Package p_BillingASL
 
/********************************************************  
   System definition
*********************************************************/

System Billing_ASL "BillingSystem " : Application: Application_Web


/********************************************************
   DataEntities view
*********************************************************/

DataEnumeration SizeKind values (SMALL "Small", REG "Regular", LARGE "Large", EXTRA "ExtraLarge")
DataEnumeration UserRoleKind values (Admin, Manager, Operator, Customer)  
DataEnumeration InvoiceStatusKind values (PEND "Pending", Approved, REJ "Rejected", Issued, Paid, Deleted)   
DataEnumeration VATRateKind values (Standard, Reduced, Special)   


  