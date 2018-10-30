public class CaseLookupController{
    
    public Boolean isGlobalSearch              {get;set;}
    public List<Case> casesList                {get;set;}
    public string onDemandCaseNumber           {get;set;}
    public string activityLogId                {get;set;}
    public Map<Id,String> userIdToMangerName   {get;set;}    
    public List<Id> userIds = new List<Id>();
    
    private Boolean firstLoad = false; //bikram
    
    public CaseLookupController(){
        firstLoad = true;       
        isGlobalSearch = false;
        String keyWord = ApexPages.currentPage().getParameters().get('Casenumber');
        system.debug('keyWord==>'+keyWord);
        if(keyWord  != ''){
            onDemandCaseNumber = keyWord ;
        }  
        activityLogId = ApexPages.currentPage().getParameters().get('activityLogId');   
        System.Debug('___activityLogId___'+activityLogId);   
        casesList = new  List<Case>(returnOnDemandCases(keyWord));
    }  
    
    public void searchGo(){
        if(onDemandCaseNumber != null){
            casesList = new  List<Case>(returnOnDemandCases(onDemandCaseNumber));
        }
    } 
    
    public List<Case> returnOnDemandCases(string searchText){
        List<Case> tempList = new List<Case>();
        List<Store_Cases_For_Month__c> listOfAlreadyStoredCases = [Select Id, Case__c from Store_Cases_For_Month__c where Manger_Activity_Log__c =: activityLogId];
        List<Id> alreadyStoredCaseIds = new List<Id>();
        for(Store_Cases_For_Month__c tempStoredCases : listOfAlreadyStoredCases){
          alreadyStoredCaseIds.add(tempStoredCases.Case__c);
        }
        
        Set<String> unWantedRecordTypes = new Set<String>(CaseRecordOrTypeIds__c.getInstance('SM_RecordType_Ids').ReferenceIds__c.split(';'));
        
        string queryParam = searchText.trim()+'%';        
        system.debug(queryParam+'queryParam ===>');
        if(searchText != ''){   
          isGlobalSearch = false;    
        } else {
            //System.Debug('___No Search Yet____');
            isGlobalSearch = true;
        }        
        String temp = '00G';
        if(firstLoad != true) tempList = [SELECT CaseNumber, Subject, Priority, Owner.Name, OwnerId, ClosedDate FROM Case WHERE Id NOT IN (Select Case__c from Store_Cases_For_Month__c where Manger_Activity_Log__c =: activityLogId) AND RecordTypeId = '01250000000UJwxAAG' AND CaseNumber LIKE :queryParam and IsClosed = True ORDER BY LastModifiedDate DESC LIMIT 1000];        
        //getManagerName(filterOutCasesNotInQueue(tempList));
        else tempList = [SELECT CaseNumber, Subject, Priority, Owner.Name, OwnerId, ClosedDate FROM Case WHERE Id NOT IN (Select Case__c from Store_Cases_For_Month__c where Manger_Activity_Log__c =: activityLogId)  AND RecordTypeId = '01250000000UJwxAAG' AND IsClosed = True and ClosedDate = Last_Month ORDER BY LastModifiedDate DESC LIMIT 20];        
        getManagerName(filterOutCasesNotInQueue(tempList));        
        firstLoad = false;
        return filterOutCasesNotInQueue(tempList);
    }

    public void getManagerName(List<Case> tempList){
        userIdToMangerName  = new Map<Id,String>();    
        for(User tempUser : [Select Id, Manager.Name from User where Id IN : userIds]){
            If(tempUser.Manager.Name != NULL)
                userIdToMangerName.put(tempUser.Id, tempUser.Manager.Name);
            else{
                userIdToMangerName.put(tempUser.Id, 'No Manager Associated');
            }
        }    
    }
    
    public List<Case> filterOutCasesNotInQueue(List<Case> tempList){
        System.Debug('_______tempList_______'+tempList.Size());
        list<Case> finalCaseList = new List<Case>();
        for(Integer i=0; i < tempList.size(); i++){
            String ownerId = tempList[i].OwnerId+'';
            if(!ownerId.trim().StartsWith('00G')){
                finalCaseList.add(tempList[i]);
                userIds.add(tempList[i].OwnerId);
            }
        }
        System.Debug('_______tempList_______'+finalCaseList);
        return finalCaseList;
    }
}