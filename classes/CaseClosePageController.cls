public class CaseClosePageController{
    public Case cse{get;set;}
    
    public CaseClosePageController(ApexPages.StandardController controller) {
        this.cse = (Case)controller.getRecord();
        this.cse = [select Id,accountId,status,contactid,Close_Reason__c,Origin,Problem_Type__c,Category__c,Sub_Category__c from case where id =: cse.id];
    }
    public void saveRecords(){
        try{
            Case cseObj = new Case(id = cse.Id,status = cse.status,accountId = cse.accountId,contactid = cse.contactid,Close_Reason__c = cse.Close_Reason__c,Origin = cse.origin,Problem_Type__c = cse.Problem_Type__c,Category__c = cse.Category__c,Sub_Category__c = cse.Sub_Category__c);
            Database.SaveResult SR = Database.update(cseObj);
        }
        catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
}