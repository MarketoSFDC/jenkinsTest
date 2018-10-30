global class SandboxPostRefresh_ACNew implements SandboxPostCopy { 
    static List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
    global void runApexClass(SandboxContext context) { 

          UpdateEmails bc4 = new UpdateEmails('select id,Primary_Marketo_User_Email__c,Accounting_Email__c,Referrer_Email_Number__c from opportunity where (((not Primary_Marketo_User_Email__c like \'%uat%\') and Primary_Marketo_User_Email__c != null) or  ((not Accounting_Email__c like \'%uat%\') and Accounting_Email__c!= null) or ((not Referrer_Email_Number__c like  \'%uat%\') and Referrer_Email_Number__c != null))','Primary_Marketo_User_Email__c;Accounting_Email__c;Referrer_Email_Number__c');
         ID batchprocessid4 = Database.executeBatch(bc4,200);
         //updatecustomlabels();
         
       
    }
    
}