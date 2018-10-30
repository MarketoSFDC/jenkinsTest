@isTest//(seeAllData= True)
public class Test_Schedule_Sales_Invoice{
    static testMethod void Met1(){
    List<Sales_Invoice__c> lstsvc = new List<Sales_Invoice__c>();
        Account ac = new Account(Name = 'Test Acc', Sales_Region__c = 'North America',Business_Unit__c = 'AMER-SB',count_SV__c=0);
        insert ac;
        
        contact cc = new contact();
        cc.FirstName = 'Grazitti';
        cc.LastName = 'Test';
        cc.AccountId = ac.Id;
        insert cc;
        
            opportunity opp = new Opportunity(name='Test1',
                                              Accountid=ac.id,
                                              Type='New Business',
                                              CloseDate=System.Today(),
                                              StageName='Discovery',
                                              Deal_Type__c='Agency',
                                              Primary_Marketo_User_Lookup__c = cc.Id,
                                              Rep_Create_ARR__c = 10,
                                              MainCompetitor__c = 'Act-On',
                                              NextStep='test',
                                              Use_Case__c='B2B',
                                              LeadSource='Blog'
                                            );
        insert opp;
        Sales_Invoice__c sv1 = new Sales_Invoice__c(Name='Test1',Amount_Due__c=1000,Opportunity__c=opp.id,Payment_Due_Date__c = System.Today().addDays(-35),Account__c=ac.id);
        lstsvc.add(sv1);
        Sales_Invoice__c sv2 = new Sales_Invoice__c(Name='Test2',Amount_Due__c=1300,Opportunity__c=opp.id,Payment_Due_Date__c = System.Today().addDays(-1),Account__c=ac.id);
        lstsvc.add(sv2);
        Sales_Invoice__c sv3 = new Sales_Invoice__c(Name='Test3',Amount_Due__c=1500,Opportunity__c=opp.id,Payment_Due_Date__c = System.Today().addDays(-45),Account__c=ac.id);
        lstsvc.add(sv3);
        insert lstsvc;
        Sales_Invoice_Payment__c sip = new Sales_Invoice_Payment__c(name ='Test1',Posting_Date__c=system.Today(),   Payment_Type__c='Payment',Sales_Invoice__c=sv1.id);
        insert sip;
        Sales_Invoice_Item__c sit= new Sales_Invoice_Item__c(Name='Test1',Sales_Invoice__c=sv1.id);
        insert sit;
        Sales_Invoice_Payment__c sip2 = new Sales_Invoice_Payment__c(name ='Test2',Posting_Date__c=system.Today(),   Payment_Type__c='Payment',Sales_Invoice__c=sv1.id);
        insert sip2;
        Sales_Invoice_Item__c sit2= new Sales_Invoice_Item__c(Name='Test2',Sales_Invoice__c=sv1.id);
        insert sit2;
        Account acc = new Account(Id=ac.Id);
        acc.count_SV__c = 0;
        update acc;
        //Schedule_Sales_Invoice ssv = new Schedule_Sales_Invoice(true);
        Schedule_Sales_Invoice ssv2 = new Schedule_Sales_Invoice();
        //ssv.accIds.add(acc.id);
        ssv2.accIds.add(acc.id);
        //ssv.execute(NULL);
        ssv2.execute(NULL);
         Sales_Invoice__c sv5 = new Sales_Invoice__c(Name='Test1',Amount_Due__c=1000,Opportunity__c=opp.id,Payment_Due_Date__c = System.Today().addDays(-35),Account__c=ac.id);
         insert sv5;
         
         delete sv5;
        
    }
}