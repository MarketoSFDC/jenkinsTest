/*************************************************************
Created By - Grazitti Support Team
Purpose - To Sync Jive API for Bizible Customers
****************************************************************/

public class JiveBizibleContactSync implements Database.Batchable<sObject>,Database.AllowsCallouts{

    public Set<Id> authIds;
    public static Integer apiCount = 0;
    public JiveBizibleContactSync (Set<Id> auths){
        authIds = auths;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,contact__c,contact__r.firstname,contact__r.lastname,contact__r.email,contact__r.accountid,entitlement__c from Authorized_Contact__c where ID IN:authIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Authorized_Contact__c> scope){         
        performJiveApiCall(scope);
    }
    
    @future(callout=true)
    public static void callJiveApi(Set<Id> authIds){
       List<Authorized_Contact__c > authContList = new List<Authorized_Contact__c >([Select id,contact__c,contact__r.firstname,contact__r.lastname,contact__r.email,contact__r.accountid,entitlement__c from Authorized_Contact__c where ID IN:authIds]);
       if(!authContList.isEmpty()){
           performJiveApiCall(authContList);
       }
    }
    
    public static void performJiveApiCall(List<Authorized_Contact__c > authContList){
        List<Authorized_Contact__c> listToUpdate = new List<Authorized_Contact__c>();
        Map<Id,String> failedAuthContacts = new Map<Id,String>();
        String endpoint = Label.JiveUserCreationEndPoint;
        String headerValueToConvert = Label.JiveCredenatials;  
        Blob headerValue;
        String body = '';
        for(Authorized_Contact__c con : authContList){
            String pwd = '';
            pwd = returnPassword();  
            headerValue = Blob.valueOf(headerValueToConvert); 
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            if(con.contact__r.email == null) con.contact__r.email = '';
            if(con.contact__r.firstname == null) con.contact__r.firstname = con.contact__r.lastname;
            if(con.contact__r.lastname == null) con.contact__r.lastname = '';
            body = '{"emails" : [ {"value" : "'+con.contact__r.email+'","jive_label" : "Email"} ],"jive" : {"password" : "'+pwd+'","username" : "'+con.contact__r.email+'","profile":[{"value":"'+con.contact__c+'","jive_label":"Contact ID"},{"value":"'+con.contact__r.AccountId+'","jive_label":"Account ID"},{"value":"'+con.entitlement__c+'","jive_label":"Entitlement"}]},"name" : {"familyName" : "'+con.contact__r.lastname+'","givenName" : "'+con.contact__r.firstname+'"}}';            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setBody(body);  
            if(!Test.IsRunningTest()) res = http.send(req);
            String sJson = res.getBody();
            System.debug('Str:' + res.getBody());
            System.debug('Str2:' + res.getStatusCode());
            if(res.getStatusCode() == 201){
                Authorized_Contact__c ac = new Authorized_Contact__c(id=con.Id,Password__c = pwd);
                listToUpdate.add(ac);
            }else if(res.getStatusCode() != 409){
                failedAuthContacts.put(con.Id,res.getBody());    
            }
        }
        if(!failedAuthContacts.isEmpty()){
            List<Jive_Sync_Errors__c> errList = new List<Jive_Sync_Errors__c>();
            for(Id ac : failedAuthContacts.keySet()){
                Jive_Sync_Errors__c err = new Jive_Sync_Errors__c();
                err.Authorized_Contact__c   = ac;
                if(failedAuthContacts.containsKey(ac)) err.API_Error_Message__c  = failedAuthContacts.get(ac);
                errList.add(err);
            }
            if(!errList.isEmpty()) Database.Insert(errList);
        }
        try{
           if(!listToUpdate.isEmpty()) update listToUpdate;
       }
       catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
    public static string returnPassword(){
        string pwd;
        Integer len = 10;     
        Blob blobKey = crypto.generateAesKey(128);   
        String key = EncodingUtil.convertToHex(blobKey);   
        pwd = key.substring(0,len);
        return pwd;
    }
    
    public void finish(Database.BatchableContext BC){    
    }   
}