/**
* @author Chris B
* @date 09/06/2018
* @description Used on the Quick Action "AE Convert" lightining component "ConvertLeadLEX"
*/
public class LeadConvertLEXController {
        
    static final String PROFILE_CAN_CONVERT = 'Account Executive';
    //static final String PROFILE_CAN_CONVERT = 'System Administrator';
    static final String RECORD_TYPE_NAME_MCL = 'MCL';
    static final String RECORD_TYPE_NAME_SCL = 'SCL';
    static final String RECORD_TYPE_NAME_INFLUENCER = 'Influencer';
    static final String RECORD_TYPE_NAME_PSA_RESOURCE = 'PSA Resource';     
    static final String SQL_STATUS = 'SQL';     
        
    @AuraEnabled 
    public static boolean validProfileForConversion(){
        // query current user information  
        Profile oProfile = [select Name FROM Profile WHERE id =:userInfo.getProfileId()];
        
        if(oProfile.Name == PROFILE_CAN_CONVERT) return true;
        
        return false;
    }

        
    @AuraEnabled 
    public static boolean validLeadStatus(Id leadId){
        try {       
            Lead leadObj = [SELECT id, Name,  Status, Account__c 
                        FROM Lead WHERE ID=:leadId];
            if(leadObj.Status == SQL_STATUS && leadObj.Account__c != NULL) return true;
            return false; 

        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled 
    public static LeadConvertResult convertLead(Id leadId){

        try {       
            Lead leadObj = [SELECT id, Name, FirstName, LastName, LeadSource, 
                        Email, Account__c, RecordTypeId, City, Country, 
                        PostalCode, State, Street,
                        mkto_si__Last_Interesting_Moment__c, mkto_si__Last_Interesting_Moment_Date__c,
                        Phone, Lead_Source_Comments__c, IsConverted, Status
                        FROM Lead WHERE ID=:leadId];
            
            Contact newContactObj = new Contact();
            newContactObj.FirstName = leadObj.FirstName; 
            newContactObj.LastName = leadObj.LastName;
            newContactObj.LeadSource = leadObj.LeadSource;
            newContactObj.Email = leadObj.Email;
            newContactObj.AccountId = leadObj.Account__c;
            newContactObj.MailingCity = leadObj.City;
            newContactObj.MailingCountry = leadObj.Country;
            newContactObj.MailingPostalCode = leadObj.PostalCode;
            newContactObj.MailingState = leadObj.State;
            newContactObj.MailingStreet = leadObj.Street;
            //newContactObj.mkto_si__Last_Interesting_Moment__c = leadObj.mkto_si__Last_Interesting_Moment__c;
            newContactObj.mkto_si__Last_Interesting_Moment_Date__c = leadObj.mkto_si__Last_Interesting_Moment_Date__c;
            newContactObj.Phone = leadObj.Phone;
            newContactObj.Lead_Source_Comments__c = leadObj.Lead_Source_Comments__c;
            
            String recordTypeName = getRecordTypeNameById('Lead', leadObj.RecordTypeId);
            
            if(recordTypeName == RECORD_TYPE_NAME_MCL || recordTypeName == RECORD_TYPE_NAME_SCL)
                    newContactObj.RecordTypeId = getRecordTypeIdbyName('Contact', RECORD_TYPE_NAME_INFLUENCER);
            else 
                    newContactObj.RecordTypeId = getRecordTypeIdbyName('Contact', RECORD_TYPE_NAME_PSA_RESOURCE);
                    
            // start new
            List<Contact> duplicateContacts = getDuplicateContacts(newContactObj, leadObj);
            LeadConvertResult result = new LeadConvertResult();
            // there are duplicates - show to user
            if(duplicateContacts != null && duplicateContacts.size() > 0) {
                result.isSuccess = false;
                result.newContact = newContactObj;
                result.duplicateContacts = duplicateContacts;
            } else { // no dupes found - convert lead
                result.isSuccess = true;
                result.convertedContactId = updateLeadAndUpsertContact(leadObj.Id, null, newContactObj);
            }
            return result;
            // end new
            
            //leadObj.Status = 'Contact';
            //update leadObj;
            
            //return newContactObj.Id;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updateLeadAndUpsertContact(String leadId, String existingContactId, Contact newContact) {
        //update new Lead(Id = leadId, Status = 'Contact');
        // bypass the duplicate rules
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr;
        if(existingContactId != null) {
            newContact.Id = existingContactId;
            sr = Database.update(newContact, dml);
        } else {
            sr = Database.insert(newContact, dml);
        }
        
        System.debug('newContact::' + sr.getId());
        
        update new Lead(Id = leadId, Status = 'Contact', Touch_Stage__c = 'Untouched', Contact__c = sr.getId());
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setConvertedStatus('Contact');
        lc.setContactId(newContact.Id);
        lc.setAccountId(newContact.AccountId);
        lc.setDoNotCreateOpportunity(true);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.debug(lcr);
        if(!lcr.isSuccess()) {
            Database.Error[] leadConvertError = lcr.getErrors();
            throw new AuraHandledException('Lead could not be converted: ' + leadConvertError.get(0));
        }
        return sr.getId();
    }
    
    private static List<Contact> getDuplicateContacts(Contact newContact, Lead leadObj) {            
        List<Contact> duplicateContacts = new List<Contact>();
        List<Datacloud.FindDuplicatesResult> dupeList = Datacloud.FindDuplicates.findDuplicates(new List<SObject>{ newContact });
        for(Datacloud.FindDuplicatesResult findDupeResult : dupeList) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        if(matchRecord.getRecord().get('Id') != leadObj.Id)
                            duplicateContacts.add((Contact)matchRecord.getRecord());
                    }
                }
            }
        }
        return duplicateContacts;
    }
    
    private static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }       

    private static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName)
    {
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    
    public class LeadConvertResult {
        @AuraEnabled
        public Boolean isSuccess {get;set;}
        @AuraEnabled
        public Id convertedContactId {get;set;}
        @AuraEnabled
        public List<Contact> duplicateContacts {get;set;}
        @AuraEnabled
        public Contact newContact {get;set;}
    }
}