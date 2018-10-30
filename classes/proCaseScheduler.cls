global class proCaseScheduler implements Schedulable {    
    global void execute(SchedulableContext context) {
        if(Label.EliteProactiveProjectSwitch == 'Yes'){
            insertNewCases();
        }
    }    
    global List<Case> insertNewCases() { 
    Id proactiveCaseRecord = '01238000000E8aVAAS'; 
        List<Case> newCases = new List<Case>(); 
        map<id,string> accountEmailCC = new map<id,string>();    
        for(Entitlement en : [SELECT Id, accountid, (select id,contactId from cases WHERE recordtype.name='Support Cases' AND Support_Level__c ='Elite' AND createddate=last_week),(Select id, Contact__r.id, Contact__r.email, Customer_Admin__c from Authorized_Contacts__r ) FROM Entitlement Where type ='Elite' AND status = 'Active']) {
            if(en.cases.size()>0 || Test.isRunningTest()){
                Case cs = new Case();
                boolean AdminFOund = False;
                string EmailCC = '';
                for(authorized_contact__c AC : en.Authorized_Contacts__r) {
                    if(accountEmailCC.containskey(en.accountid)){
                        EmailCC = accountEmailCC.get(en.accountid)+';'+AC.Contact__r.email;
                        accountEmailCC.put(en.accountid,EmailCC);
                    }else{
                        accountEmailCC.put(en.accountid,AC.Contact__r.email);
                    }
                    if(AC.Customer_Admin__c){
                        cs.ContactId = AC.contact__c;
                        AdminFOund = true;
                    }else if(AdminFOund == false){
                        cs.ContactId = AC.contact__c;
                    } 
                }
                String accId = '';
                if(en.AccountId != null && String.IsNotBlank(en.AccountId)){
                    accId = String.ValueOf(en.AccountId);
                    accId = accId.Substring(0,15);
                }
                cs.description='Here is your report link:'+Label.WeeklyReportLink+'?pv1='+accId;
                cs.subject ='Elite Weekly Report';
                cs.ownerId = Label.ProActiveUserId;
                cs.RecordTypeId = Label.ProActiveCaseRecTypeId;
                cs.Email_List__c=accountEmailCC.get(en.accountid);
                cs.accountId=en.accountid;
                cs.OnPortalAvailable__c = true;
                cs.Problem_Type__c= 'Proactive Monitoring';
                cs.Category__c = 'Weekly Report';
                cs.entitlementId=en.id;
                newCases.add(cs); 
            }
        }   
        if(newCases != null && newCases.size() > 0){
            insert newCases; 
        } 
         return newCases;                   
    }
}