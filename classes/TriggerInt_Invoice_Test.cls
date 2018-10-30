/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :TriggerInt_Invoice_Test
**************************************************************************************************************************************/

@isTest
public class TriggerInt_Invoice_Test{
    static testmethod void MapFieldsAndPublishIntegrationPlatformEvent()
    {
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 1);
        List<pse__Milestone__c> milestone_list = TestCPQUtilityClass.createMilestone(project_list, 1);
        List<Sales_Invoice__c> salesInv_list = TestCPQUtilityClass.createSalesInvoice(opp_list,1);
        
        insert acc_list;
        insert contact_list;
        for(Opportunity opp :opp_list)
        {
            opp.Type = 'New Business';
        }
        insert opp_list;
         insert project_list;
        for(pse__Proj__c Proj : project_list)
        {
            Proj.int_Intacct_Record_No__c = 'Test';
            Proj.pse__Is_Active__c = True;
        }
        
        update project_list;
        
        pse__Proj__c proj = project_list[0];
        for(pse__Milestone__c milestone : milestone_list)
        {
            milestone.int_IsSyncing__c  = False;
            milestone.int_Intacct_Project_ID_2__c = 'Test';
            milestone.int_Intacct_Project_Category__c = 'Contract';
            milestone.pse__Project__c = proj.id;
            milestone.int_Intacct_Project_ID_2__c = 'MS-0001636';
        }
        Insert milestone_list;
        
        Intacct_Entity__c IntEntObj = new Intacct_Entity__c();
        IntEntObj.Name = 'Test';
        insert IntEntObj;
        
          for(Sales_Invoice__c salesObj : salesInv_list){
            salesObj.Intacct_Entity__c = IntEntObj.Id;
            salesObj.Document_Type__c = 'Test';
            salesObj.int_Approval_Status__c ='Not Reviewed';
            
            //  salesObj.int_IsSyncing__c = True;
          }
          insert salesInv_list;
            
        for(Sales_Invoice__c salesObj : salesInv_list){
            salesObj.int_IsSyncing__c = True;
           
            salesObj.Integration_Status__c = 'In-Progress';
            salesObj.int_Intacct_Project_ID__c = 'MS-0001636';
             SF_Utility.isCalloutExecuted = false;
        }
        
        test.startTest();
            update salesInv_list;
        test.stopTest();
        system.debug('******salesInv_list******'+salesInv_list);
        Sales_Invoice_Item__c salesInvoiceItemObj = new Sales_Invoice_Item__c();
        salesInvoiceItemObj.Name = 'Test sales Invoice Item';
        salesInvoiceItemObj.Sales_Invoice__c = salesInv_list[0].id;
        insert salesInvoiceItemObj ;
        
        salesInvoiceItemObj.Name = 'Test sales Invoice Item1';
        update salesInvoiceItemObj;
               
    }
    
     static testmethod void isSpecifiedFieldUpdated()
    {
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 1);
        List<pse__Milestone__c> milestone_list = TestCPQUtilityClass.createMilestone(project_list, 1);
        List<Sales_Invoice__c> salesInv_list = TestCPQUtilityClass.createSalesInvoice(opp_list,1);
        
        insert acc_list;
        insert contact_list;
        for(Opportunity opp :opp_list)
        {
            opp.Type = 'New Business';
        }
        insert opp_list;
         insert project_list;
        for(pse__Proj__c Proj : project_list)
        {
            Proj.int_Intacct_Record_No__c = 'Test';
            Proj.pse__Is_Active__c = True;
        }
        
        update project_list;
        
        pse__Proj__c proj = project_list[0];
        for(pse__Milestone__c milestone : milestone_list)
        {
            milestone.int_IsSyncing__c  = False;
            milestone.int_Intacct_Project_ID_2__c = 'Test';
            milestone.int_Intacct_Project_Category__c = 'Contract';
            milestone.pse__Project__c = proj.id;
            milestone.int_Intacct_Project_ID_2__c = 'MS-0001636';
        }
        Insert milestone_list;
        
        Intacct_Entity__c IntEntObj = new Intacct_Entity__c();
        IntEntObj.Name = 'Test';
        insert IntEntObj;
        
          for(Sales_Invoice__c salesObj : salesInv_list){
            salesObj.Intacct_Entity__c = IntEntObj.Id;
            salesObj.Document_Type__c = 'Test';
            salesObj.int_Approval_Status__c ='Not Reviewed';
            salesObj.Integration_Status__c = 'Success';
            //  salesObj.int_IsSyncing__c = True;
          }
          insert salesInv_list;
            
        for(Sales_Invoice__c salesObj : salesInv_list){
            salesObj.int_IsSyncing__c = True;
           
            salesObj.Integration_Status__c = 'In-Progress';
            salesObj.int_Intacct_Project_ID__c = 'MS-0001637';
           
            salesObj.Document_Type__c='test 1234'+salesObj.name;
            salesObj.int_IsSyncing__c = True;
        }
        
        test.startTest();
        
        SF_Utility.isCalloutExecuted = false;
            update salesInv_list;
        test.stopTest();
        system.debug('******salesInv_list******'+salesInv_list);
        Sales_Invoice_Item__c salesInvoiceItemObj = new Sales_Invoice_Item__c();
        salesInvoiceItemObj.Name = 'Test sales Invoice Item';
        salesInvoiceItemObj.Sales_Invoice__c = salesInv_list[0].id;
        SF_Utility.isCalloutExecuted = false;
        insert salesInvoiceItemObj ;
        
        salesInvoiceItemObj.Name = 'Test sales Invoice Item1';
        update salesInvoiceItemObj;
  
    }
     static testmethod void DeleteSalesInvoice(){   
      List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
       insert acc_list;
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
         insert contact_list;
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        
        List<Sales_Invoice__c> salesInv_list = TestCPQUtilityClass.createSalesInvoice(opp_list,1);
        
       
       
        for(Opportunity opp :opp_list)
        {
            opp.Type = 'New Business';
        }
        insert opp_list;
        
        
        Intacct_Entity__c IntEntObj = new Intacct_Entity__c();
        IntEntObj.Name = 'Test';
        insert IntEntObj;
        
          for(Sales_Invoice__c salesObj : salesInv_list){
            salesObj.Intacct_Entity__c = IntEntObj.Id;
            salesObj.Document_Type__c = 'Test';
            salesObj.int_Approval_Status__c ='Not Reviewed';
            
           
          }
          insert salesInv_list;     
          delete salesInv_list;
        SalesTriggersUtility.Setvaluesfortest();
        SalesTriggersUtility.Settruevaluesfortest();  
    }
    
}