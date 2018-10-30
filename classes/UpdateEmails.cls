global class UpdateEmails implements Database.Batchable<sObject>
{
    global final String Query;
    global final string EmailFields;
    global UpdateEmails(String q, String e){Query=q;EmailFields=e;}
    global Database.QueryLocator start(Database.BatchableContext BC)
{
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<sObject> sObjectListForUpdate = new List<sObject>();
        for(sObject s : scope){
            sObject newSObject = (sObject)s;
            for (String emailFld : EmailFields.split(';')) {
                if (newSObject.get(emailFld) != null) {
                    string updatedEmail = String.valueOf(newSObject.get(EmailFld)) + '.UAT';
                    newSObject.put(EmailFld, updatedEmail);
                }
            }
            sObjectListForUPdate.add(newSObject);
        }
        database.update(sObjectListForUpdate, false);
    }
    global void finish(Database.BatchableContext BC){
        integer jobcount =[SELECT count() FROM AsyncApexJob where ApexClass.name='UpdateEmails' and (Not status in ('Completed','Failed'))];
        if(jobcount<=1){
            list<Marketo_Trigger_Management__c> mkttrigger = [select id from Marketo_Trigger_Management__c];
            if(mkttrigger!=null && !mkttrigger.isempty()){
                Marketo_Trigger_Management__c marketoTriggerManager=new Marketo_Trigger_Management__c (id=mkttrigger[0].id);
                marketoTriggerManager.Deactivate_Account_Triggers__c= False;
                marketoTriggerManager.Deactivate_Asset_Triggers__c= False;
                marketoTriggerManager.Deactivate_Contact_Triggers__c= False;
                marketoTriggerManager.Deactivate_Contract_Triggers__c= False;
                marketoTriggerManager.Deactivate_Entitlements_Triggers__c= False;
                marketoTriggerManager.Deactivate_Legacy_QLI_Triggers__c= False;
                marketoTriggerManager.Deactivate_Legacy_Quote_Triggers__c= False;
                marketoTriggerManager.Deactivate_OLI_Triggers__c= False;
                marketoTriggerManager.Deactivate_Opportunity_Triggers__c= False;
                marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c= False;
                marketoTriggerManager.Deactivate_Subscription_Triggers__c= False;
                marketoTriggerManager.Deactivate_User_Triggers__c= False;
                marketoTriggerManager.Deactivate_Project_Triggers__c = False;
                marketoTriggerManager.Deactivate_Timecard_Split_Triggers__c = False;
                marketoTriggerManager.Deactivate_Sales_Invoice_Triggers__c = False;
                marketoTriggerManager.Deactivate_Assignment_Triggers__c = False;
                marketoTriggerManager.Deactivate_Milestone_Triggers__c = False;
                update marketoTriggerManager;
            }
        }
    }
}