public class OpportunityRecordTypeSelection {
    
    public Opportunity OppRecord{get;set;}
    public static Map<Id, String> recordtypemap {get;set;}
    
   @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Opportunity.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        
        for(RecordTypeInfo rt : recordtypes){
            //Check the availability of recordtype for the respective users
            if(rt.isAvailable()){
            
                if(rt.getName() != 'Master')
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }        
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
       // system.debug('===recordTypeLabel======'+recordTypeLabel);
        Id recid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
       // system.debug('===recid======'+recid);
        return recid;
    }
    
    @AuraEnabled
    
    public Static Contact fetchCaseRecordDetail(Id conId)
    {

        //system.debug('=caseId=='+caseId);
        return  [SELECT Id,Referrer_Notes__c,SDR_Owner_Look_Up__c,SDR_Owner_Look_Up__r.Id,SDR_Owner_Look_Up__r.FirstName,SDR_Owner_Look_Up__r.LastName,/*Account.CRM_System__c,*/Account.Name,AccountId,LeadSource,Lead_Source_Comments__c,/*Lead_Category__c, */Buying_Behavior__c,SDR_Owner__c,Referrer_First_Name__c,Referrer_Last_Name__c,Referrer_Email_Number__c,Referrer_Phone_Number__c,Date_Referral_Submitted__c,Referral_Indicator__c,Referring_Partner__c,account.website,account.Use_Casenew__c, account.Account_Currency_Formula__c, account.CurrencyIsoCode  FROM Contact Where ID =:conId Limit 1];
    }
    
    @AuraEnabled 
    public static user fetchUser(){
     // query current user information  
      User oUser = [select BOFU_Wizard_Enabled__c,id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                 FROM User Where id =: userInfo.getUserId()];
        return oUser;
    }
    

}