/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 14,18

**********************************************************************/

global class SupportAdminOnActiveEntitlementPopulater implements Schedulable {
    global void execute(SchedulableContext SC) {    
        //CODE TO POPULATE THE SUPPORT ADMIN CONTACT FIELD ON ENTITLEMENT 
        Map<Id, Entitlement> TriggerNewMap = new Map<Id, Entitlement>(); 
        List<Entitlement> supportAdminEntsListToBeupdated = new List<entitlement>();        
        for(Entitlement ent :[SELECT (SELECT Contact__c, Customer_Admin__c FROM Authorized_Contacts__r WHERE Customer_Admin__c =: true LIMIT 1),Support_Admin_Contact__c,Account.Type,Asset.Status,TYPE,AssignedSupportPOC__c,Status, Account.BillingState, Support_Region__c  FROM Entitlement WHERE StartDate = TODAY]){
            TriggerNewMap.put(ent.Id, ent);            
            //Sops-968
            Boolean addToUpdateList = False;                
            if(ent.Type == 'Business' &&  ent.AssignedSupportPOC__c== Null) {
                addToUpdateList = True;
            }
            //Ends             
            if(ent.Support_Admin_Contact__c == Null && ent.Account.Type != 'Ex-Customer' && ent.Account.Type != 'Ex-Partner' && ent.Asset.Status != 'Expired' && ent.TYPE != System.Label.Entitlement_Type_Label){
                for(Authorized_Contact__c ac : ent.Authorized_Contacts__r) {
                    ent.support_Admin_Contact__c = ac.Contact__c ;
                    supportAdminEntsListToBeupdated.add(ent);
                    addToUpdateList = False;//Sops-968                   
                }
            }            
            if(addToUpdateList) supportAdminEntsListToBeupdated.add(ent);//Sops-968
        } 
        if(!TriggerNewMap.isempty()){      
            UpdateEntitlements_Trigger.updateEntitlementAccount(TriggerNewMap);
        }
        //CODE TO POPULATE THE PRIMARY MARKETO USER FIELD ON ENTITLEMENT       
        List<Entitlement> learningPassportListToBeUpdated = new List<Entitlement>();
        For(Entitlement Entt : [SELECT Primary_Marketo_User_Email_Hidden__c, Opportunity__r.Primary_Marketo_User_Lookup__r.Email, Account.Type FROM Entitlement WHERE StartDate =: Date.TODAY() AND Opportunity__r.Primary_Marketo_User_Lookup__r.Email != Null AND Type =: System.Label.Entitlement_Type_Label]){
            System.Debug('Entitlement >>>>>');
            Entt.Primary_Marketo_User_Email_Hidden__c = Entt.Opportunity__r.Primary_Marketo_User_Lookup__r.Email;
            learningPassportListToBeUpdated.add(Entt);
        }
        If(!learningPassportListToBeUpdated.isEmpty()){
            supportAdminEntsListToBeupdated.addAll(learningPassportListToBeUpdated);
        }       
        Database.SaveResult[] sr = Database.update(supportAdminEntsListToBeupdated, False);        
     }
     
     static testMethod void testActiveEntitlementPopulater(){ 
        Account a  = Utility.insertAccountInTestClasses();
        a.Temperature__c = 'Green';
        a.Success_Score_Updated__c = Date.Today().addDays(-100);
        a.Temp_Executive_Summary_Last_Update__c = Date.Today().addDays(-100);
        a.Type = 'Competitor';
        insert a;
        Contact c = Utility.insertContactInTestClasses(a.ID);
        c.firstname ='tesing';
        insert c;
        Entitlement e =  new Entitlement(Name = 'Test',AccountID = a.ID, OK_to_Add__c = true, StartDate =Date.TODAY(),Type ='Business' );
        insert e;
        Authorized_Contact__c ac = new Authorized_Contact__c(Contact__c= c.ID,Customer_Admin__c=true,Entitlement__c=e.ID);
        insert ac;
        Opportunity o = Utility.insertOpportunityInTestClasses(a.ID, c.ID, 'A - Qualify', 'New Business', Date.TODAY(), Date.TODAY(), Date.TODAY(), Date.TODAY());
        o.Primary_Marketo_User_Lookup__c= c.ID;
        insert o;
        Entitlement e2 = new Entitlement(Name = 'Test2',AccountID = a.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = o.ID );
        insert e2;
        Test.StartTest();
        SupportAdminOnActiveEntitlementPopulater  sh1 = new SupportAdminOnActiveEntitlementPopulater ();    
        sh1.execute(Null);
        Test.stopTest();    
    }
}